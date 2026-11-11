// Small, allocation-free DSP building blocks shared by the analysis pipeline.
// Everything that depends on time takes an explicit `dt` in seconds so the
// behaviour is independent of the analysis rate.
#ifndef NOXIRA_DSP_COMMON_H_
#define NOXIRA_DSP_COMMON_H_

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <vector>

namespace noxira {

constexpr float kSilenceDb = -200.0f;
constexpr float kPi = 3.14159265358979323846f;

inline float clamp01(float v) { return v < 0.0f ? 0.0f : (v > 1.0f ? 1.0f : v); }

inline float clampf(float v, float lo, float hi) {
  return v < lo ? lo : (v > hi ? hi : v);
}

// Linear amplitude -> dBFS, floored so silence never produces -inf/NaN.
inline float amplitudeToDb(float amplitude) {
  return amplitude > 1e-10f ? 20.0f * std::log10(amplitude) : kSilenceDb;
}

// Exponential smoothing coefficient for a time constant; tau <= 0 snaps.
inline float smoothingAlpha(float dt, float tauSeconds) {
  return tauSeconds <= 1e-6f ? 1.0f : 1.0f - std::exp(-dt / tauSeconds);
}

// Moves `value` towards `target` with separate attack (rising) and release
// (falling) time constants, in seconds.
inline float attackRelease(float value, float target, float dt, float attackSec,
                           float releaseSec) {
  const float tau = target > value ? attackSec : releaseSec;
  return value + (target - value) * smoothingAlpha(dt, tau);
}

// Maps dBFS levels to 0..1 with 6 dB of headroom. The default shared reference
// preserves relative band levels instead of independently boosting each band.
// A lower bound limits gain in quiet passages; the caller handles the noise gate.
class DynamicNormalizer {
 public:
  // `attackSec` is how fast the reference rises towards louder content (0 =
  // instantly follows peaks; larger values let short peaks overshoot to 1
  // instead of pulling every other band down for seconds).
  void configure(int count, float rangeDb, float minReferenceDb,
                 float releaseDbPerSec, float globalMix, float attackSec = 0.0f) {
    count_ = count;
    attackSec_ = std::max(attackSec, 0.0f);
    rangeDb_ = std::max(rangeDb, 6.0f);
    minRefDb_ = minReferenceDb;
    releaseDbPerSec_ = std::max(releaseDbPerSec, 0.0f);
    globalMix_ = clamp01(globalMix);
    refs_.assign(static_cast<size_t>(count), minReferenceDb);
    globalRef_ = minReferenceDb;
  }

  void reset() {
    std::fill(refs_.begin(), refs_.end(), minRefDb_);
    globalRef_ = minRefDb_;
  }

  float globalReferenceDb() const { return std::max(minRefDb_, globalRef_); }
  float rangeDb() const { return rangeDb_; }

  // Maps `db` against the references left by the last process() call without
  // updating them (used so left/right bands stay comparable to the mix).
  void apply(const float* db, float* out) const {
    for (int i = 0; i < count_; ++i) {
      const float ref = std::max(
          minRefDb_, globalMix_ * globalRef_ + (1.0f - globalMix_) * refs_[i]);
      out[i] = clamp01((db[i] - (ref - rangeDb_)) / rangeDb_);
    }
  }

  // `db` holds `count` levels (kSilenceDb for silence); `out` gets 0..1.
  void process(const float* db, float* out, float dt) {
    const float fall = releaseDbPerSec_ * dt;
    const float rise = smoothingAlpha(dt, attackSec_);
    float frameMax = kSilenceDb;
    for (int i = 0; i < count_; ++i) frameMax = std::max(frameMax, db[i]);
    globalRef_ = std::max(minRefDb_, follow(globalRef_, frameMax + kHeadroomDb, rise, fall));
    for (int i = 0; i < count_; ++i) {
      refs_[i] = std::max(minRefDb_, follow(refs_[i], db[i] + kHeadroomDb, rise, fall));
      const float ref =
          std::max(minRefDb_, globalMix_ * globalRef_ + (1.0f - globalMix_) * refs_[i]);
      out[i] = clamp01((db[i] - (ref - rangeDb_)) / rangeDb_);
    }
  }

 private:
  static constexpr float kHeadroomDb = 6.0f;
  // Rises towards `target` with the attack coefficient, otherwise falls
  // linearly (in dB) but never below the target.
  static float follow(float ref, float target, float rise, float fall) {
    if (target > ref) return ref + (target - ref) * rise;
    return std::max(target, ref - fall);
  }

  int count_ = 0;
  float attackSec_ = 0.0f;
  float rangeDb_ = 45.0f;
  float minRefDb_ = -40.0f;
  float releaseDbPerSec_ = 3.0f;
  float globalMix_ = 0.5f;
  float globalRef_ = -40.0f;
  std::vector<float> refs_;
};

// Adaptive-threshold onset detector for a novelty curve (e.g. spectral flux).
// A frame triggers when the novelty exceeds mean + k * stddev of the recent
// past, is still rising, and the refractory period has elapsed.
class OnsetTracker {
 public:
  struct Result {
    bool triggered = false;
    float strength = 0.0f;  // 0..1, only meaningful when triggered
  };

  void configure(float analysisRateHz, float historySeconds, float refractorySeconds,
                 float minNovelty, float sensitivity) {
    const int n = std::max(4, static_cast<int>(analysisRateHz * historySeconds));
    history_.assign(static_cast<size_t>(n), 0.0f);
    head_ = 0;
    filled_ = 0;
    refractory_ = refractorySeconds;
    minNovelty_ = minNovelty;
    // sensitivity 1 -> k = 1.0 (eager), 0 -> k = 3.5 (conservative)
    k_ = 3.5f - 2.5f * clamp01(sensitivity);
    sinceLast_ = 1e6f;
    prev_ = 0.0f;
  }

  void reset() {
    std::fill(history_.begin(), history_.end(), 0.0f);
    head_ = 0;
    filled_ = 0;
    sinceLast_ = 1e6f;
    prev_ = 0.0f;
  }

  Result update(float novelty, float dt) {
    Result r;
    sinceLast_ += dt;
    float mean = 0.0f, var = 0.0f;
    if (filled_ > 0) {
      for (int i = 0; i < filled_; ++i) mean += history_[i];
      mean /= static_cast<float>(filled_);
      for (int i = 0; i < filled_; ++i) {
        const float d = history_[i] - mean;
        var += d * d;
      }
      var /= static_cast<float>(filled_);
    }
    const float threshold = std::max(minNovelty_, mean + k_ * std::sqrt(var));
    if (filled_ >= 4 && novelty > threshold && novelty >= prev_ &&
        sinceLast_ >= refractory_) {
      r.triggered = true;
      r.strength = clamp01((novelty - threshold) / std::max(novelty, 1e-6f) * 2.0f + 0.2f);
      sinceLast_ = 0.0f;
    }
    history_[head_] = novelty;
    head_ = (head_ + 1) % static_cast<int>(history_.size());
    filled_ = std::min(filled_ + 1, static_cast<int>(history_.size()));
    prev_ = novelty;
    return r;
  }

 private:
  std::vector<float> history_;
  int head_ = 0;
  int filled_ = 0;
  float refractory_ = 0.1f;
  float minNovelty_ = 0.02f;
  float k_ = 2.0f;
  float sinceLast_ = 1e6f;
  float prev_ = 0.0f;
};

}  // namespace noxira

#endif  // NOXIRA_DSP_COMMON_H_
