#include "analysis_engine.h"

#include <time.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstring>

#include "dsp/pcm_convert.h"

namespace noxira {

// The byte layout of NoxiraAudioFrame is read by Dart through fixed offsets.
static_assert(sizeof(NoxiraAudioFrame) == 18688, "NoxiraAudioFrame size changed");
static_assert(offsetof(NoxiraAudioFrame, timestamp_us) == 0, "layout");
static_assert(offsetof(NoxiraAudioFrame, sequence) == 8, "layout");
static_assert(offsetof(NoxiraAudioFrame, state) == 24, "layout");
static_assert(offsetof(NoxiraAudioFrame, flags) == 56, "layout");
static_assert(offsetof(NoxiraAudioFrame, visualizer_spectrum_count) == 60, "layout");
static_assert(offsetof(NoxiraAudioFrame, rms) == 64, "layout");
static_assert(offsetof(NoxiraAudioFrame, peak_right) == 156, "layout");
static_assert(offsetof(NoxiraAudioFrame, regions) == 192, "layout");
static_assert(offsetof(NoxiraAudioFrame, bands) == 256, "layout");
static_assert(offsetof(NoxiraAudioFrame, bands_left) == 768, "layout");
static_assert(offsetof(NoxiraAudioFrame, bands_right) == 1280, "layout");
static_assert(offsetof(NoxiraAudioFrame, band_peaks) == 1792, "layout");
static_assert(offsetof(NoxiraAudioFrame, spectrum) == 2304, "layout");
static_assert(offsetof(NoxiraAudioFrame, waveform_left) == 6400, "layout");
static_assert(offsetof(NoxiraAudioFrame, waveform_right) == 8448, "layout");
static_assert(offsetof(NoxiraAudioFrame, visualizer_spectrum) == 10496, "layout");

// Same for the config and stats structs (marshalled by Dart FFI).
static_assert(sizeof(NoxiraConfig) == 644, "NoxiraConfig size changed");
static_assert(offsetof(NoxiraConfig, fft_size) == 4, "layout");
static_assert(offsetof(NoxiraConfig, stereo_bands) == 16, "layout");
static_assert(offsetof(NoxiraConfig, min_hz) == 32, "layout");
static_assert(offsetof(NoxiraConfig, region_edges_hz) == 40, "layout");
static_assert(offsetof(NoxiraConfig, attack_ms) == 72, "layout");
static_assert(offsetof(NoxiraConfig, sensitivity_tilt_db_per_octave) == 104, "layout");
static_assert(offsetof(NoxiraConfig, band_sensitivity_db) == 108, "layout");
static_assert(offsetof(NoxiraConfig, onset_sensitivity) == 620, "layout");
static_assert(offsetof(NoxiraConfig, latency_compensation_ms) == 624, "layout");
static_assert(offsetof(NoxiraConfig, contrast) == 628, "layout");
static_assert(offsetof(NoxiraConfig, global_reference_mix) == 632, "layout");
static_assert(offsetof(NoxiraConfig, level_floor) == 636, "layout");
static_assert(offsetof(NoxiraConfig, normalization_attack_ms) == 640, "layout");
static_assert(sizeof(NoxiraStats) == 72, "NoxiraStats size changed");
static_assert(offsetof(NoxiraStats, active_sources) == 32, "layout");
static_assert(offsetof(NoxiraStats, avg_process_us) == 40, "layout");
static_assert(offsetof(NoxiraStats, cpu_percent) == 56, "layout");

namespace {

using Clock = std::chrono::steady_clock;

constexpr uint32_t kRingFrames = 1u << 16;  // ~1.4 s at 48 kHz
constexpr double kInitialLeadSeconds = 0.25;
constexpr auto kIdlePeriod = std::chrono::milliseconds(100);

int64_t nowNs() {
  return std::chrono::duration_cast<std::chrono::nanoseconds>(
             Clock::now().time_since_epoch())
      .count();
}

int64_t threadCpuNs() {
  timespec ts;
  if (clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts) != 0) return 0;
  return static_cast<int64_t>(ts.tv_sec) * 1000000000LL + ts.tv_nsec;
}

void atomicMax(std::atomic<uint64_t>& target, uint64_t value) {
  uint64_t current = target.load(std::memory_order_relaxed);
  while (value > current &&
         !target.compare_exchange_weak(current, value, std::memory_order_relaxed)) {
  }
}

std::atomic<int64_t> g_startNs{0};

}  // namespace

AnalysisEngine& AnalysisEngine::instance() {
  static AnalysisEngine engine;
  return engine;
}

AnalysisEngine::AnalysisEngine() {
  fillDefaultConfig(&pendingConfig_);
  activeConfig_ = pendingConfig_;
  for (int i = 0; i < 3; ++i) {
    NoxiraAudioFrame* f = frames_.slot(i);
    std::memset(f, 0, sizeof(*f));
    f->struct_size = sizeof(NoxiraAudioFrame);
    f->abi_version = NOXIRA_ABI_VERSION;
    f->state = NOXIRA_STATE_INACTIVE;
  }
}

AnalysisEngine::~AnalysisEngine() { stop(); }

// ---------------------------------------------------------------- lifecycle

void AnalysisEngine::ensureRings() {
  // Called with lifecycleMutex_ held.
  for (auto& s : sources_) {
    if (s.inUse.load(std::memory_order_acquire) &&
        s.ring.load(std::memory_order_acquire) == nullptr) {
      s.ring.store(new StereoRing(kRingFrames), std::memory_order_release);
    }
  }
}

bool AnalysisEngine::start(const NoxiraConfig& config) {
  std::lock_guard<std::mutex> lock(lifecycleMutex_);
  NoxiraConfig sanitized = config;
  sanitizeConfig(&sanitized);
  {
    std::lock_guard<std::mutex> cfgLock(configMutex_);
    pendingConfig_ = sanitized;
  }
  configDirty_.store(true, std::memory_order_release);
  if (running_.load(std::memory_order_acquire)) return true;

  ensureRings();
  for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) {
    if (sources_[i].inUse.load(std::memory_order_acquire)) flushSource(i);
  }
  for (auto& c : cursors_) c = Cursor{};
  discontinuities_ = 0;
  lastPublishedState_ = -1;
  lastWasIdle_ = false;
  pendingDiscontinuity_ = false;
  sequence_ = 0;
  pipelineRate_ = 0.0f;
  framesPublished_ = 0;
  pushCalls_ = 0;
  pushedFrames_ = 0;
  ringOverruns_ = 0;
  pushNsTotal_ = pushNsMax_ = processNsTotal_ = processNsMax_ = 0;
  processedFrames_ = 0;
  cpuNsTotal_ = 0;
  g_startNs.store(nowNs(), std::memory_order_relaxed);

  stopRequested_.store(false, std::memory_order_release);
  running_.store(true, std::memory_order_release);
  try {
    thread_ = std::thread([this] { threadMain(); });
  } catch (...) {
    running_.store(false, std::memory_order_release);
    return false;
  }
  return true;
}

bool AnalysisEngine::updateConfig(const NoxiraConfig& config) {
  NoxiraConfig sanitized = config;
  sanitizeConfig(&sanitized);
  {
    std::lock_guard<std::mutex> cfgLock(configMutex_);
    pendingConfig_ = sanitized;
  }
  configDirty_.store(true, std::memory_order_release);
  wake_.store(true, std::memory_order_release);
  wakeCv_.notify_all();
  return true;
}

void AnalysisEngine::stop() {
  std::lock_guard<std::mutex> lock(lifecycleMutex_);
  if (!thread_.joinable() && !running_.load(std::memory_order_acquire)) return;
  stopRequested_.store(true, std::memory_order_release);
  {
    std::lock_guard<std::mutex> wakeLock(wakeMutex_);
  }
  wakeCv_.notify_all();
  if (thread_.joinable()) thread_.join();
  running_.store(false, std::memory_order_release);
  // Sources may be flushed while stopped; the next start rebuilds cursors.
  for (auto& s : sources_) s.exactStart.store(0, std::memory_order_release);
}

void AnalysisEngine::shutdown() { stop(); }

void AnalysisEngine::setPlaybackState(int state) {
  playbackState_.store(state, std::memory_order_release);
  wake_.store(true, std::memory_order_release);
  {
    std::lock_guard<std::mutex> wakeLock(wakeMutex_);
  }
  wakeCv_.notify_all();
}

const NoxiraAudioFrame* AnalysisEngine::acquireFrame() { return frames_.acquire(); }

void AnalysisEngine::setCallback(NoxiraFrameCallback callback) {
  callback_.store(callback, std::memory_order_release);
}

void AnalysisEngine::getStats(NoxiraStats* out) const {
  std::memset(out, 0, sizeof(*out));
  out->frames_published = framesPublished_.load(std::memory_order_relaxed);
  out->push_calls = pushCalls_.load(std::memory_order_relaxed);
  out->pushed_frames = pushedFrames_.load(std::memory_order_relaxed);
  out->ring_overruns = ringOverruns_.load(std::memory_order_relaxed);
  out->running = running_.load(std::memory_order_acquire) ? 1 : 0;
  int active = 0;
  for (const auto& s : sources_) active += s.inUse.load(std::memory_order_relaxed) ? 1 : 0;
  out->active_sources = active;
  const int64_t processed = processedFrames_.load(std::memory_order_relaxed);
  if (processed > 0) {
    out->avg_process_us =
        static_cast<float>(processNsTotal_.load(std::memory_order_relaxed)) / processed / 1000.0f;
  }
  out->max_process_us = static_cast<float>(processNsMax_.load(std::memory_order_relaxed)) / 1000.0f;
  const int64_t pushes = pushCalls_.load(std::memory_order_relaxed);
  if (pushes > 0) {
    out->avg_push_us =
        static_cast<float>(pushNsTotal_.load(std::memory_order_relaxed)) / pushes / 1000.0f;
  }
  out->max_push_us = static_cast<float>(pushNsMax_.load(std::memory_order_relaxed)) / 1000.0f;
  const int64_t wall = nowNs() - g_startNs.load(std::memory_order_relaxed);
  if (out->running && wall > 0) {
    out->cpu_percent =
        100.0f * static_cast<float>(cpuNsTotal_.load(std::memory_order_relaxed)) / wall;
  }
}

// ------------------------------------------------------------------ sources

int AnalysisEngine::acquireSource() {
  for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) {
    int expected = 0;
    if (sources_[i].inUse.compare_exchange_strong(expected, 1, std::memory_order_acq_rel)) {
      Source& s = sources_[i];
      s.sampleRate.store(0, std::memory_order_relaxed);
      s.channels.store(0, std::memory_order_relaxed);
      s.ended.store(0, std::memory_order_relaxed);
      s.order.store(orderCounter_.fetch_add(1, std::memory_order_relaxed) + 1,
                    std::memory_order_relaxed);
      if (running_.load(std::memory_order_acquire)) {
        std::lock_guard<std::mutex> lock(lifecycleMutex_);
        ensureRings();
      }
      flushSource(i);
      return i;
    }
  }
  return -1;
}

void AnalysisEngine::releaseSource(int id) {
  if (id < 0 || id >= NOXIRA_MAX_SOURCES) return;
  sources_[id].inUse.store(0, std::memory_order_release);
  sources_[id].epoch.fetch_add(1, std::memory_order_acq_rel);
  wake_.store(true, std::memory_order_release);
}

void AnalysisEngine::configureSource(int id, int sampleRate, int channels) {
  if (id < 0 || id >= NOXIRA_MAX_SOURCES) return;
  Source& s = sources_[id];
  s.sampleRate.store(sampleRate, std::memory_order_relaxed);
  s.channels.store(channels, std::memory_order_relaxed);
  s.order.store(orderCounter_.fetch_add(1, std::memory_order_relaxed) + 1,
                std::memory_order_relaxed);
  flushSource(id);
}

void AnalysisEngine::flushSource(int id) {
  if (id < 0 || id >= NOXIRA_MAX_SOURCES) return;
  Source& s = sources_[id];
  s.clockTimeNs.store(0, std::memory_order_release);
  StereoRing* ring = s.ring.load(std::memory_order_acquire);
  s.streamStart.store(ring ? ring->head() : 0, std::memory_order_release);
  s.exactStart.store(running_.load(std::memory_order_acquire) ? 1 : 0,
                     std::memory_order_release);
  s.ended.store(0, std::memory_order_release);
  s.epoch.fetch_add(1, std::memory_order_acq_rel);
  wake_.store(true, std::memory_order_release);
}

void AnalysisEngine::endSource(int id) {
  if (id < 0 || id >= NOXIRA_MAX_SOURCES) return;
  sources_[id].ended.store(1, std::memory_order_release);
  wake_.store(true, std::memory_order_release);
}

void AnalysisEngine::updateClock(int id, int64_t queuedEndUs, int64_t audibleUs, float speed) {
  if (id < 0 || id >= NOXIRA_MAX_SOURCES || !running()) return;
  Source& s = sources_[id];
  StereoRing* ring = s.ring.load(std::memory_order_acquire);
  const int sampleRate = s.sampleRate.load(std::memory_order_relaxed);
  if (ring == nullptr || sampleRate <= 0 || !std::isfinite(speed) || speed <= 0) return;
  const double delayFrames = std::max(0.0, static_cast<double>(queuedEndUs - audibleUs)) *
                             sampleRate / (1e6 * speed);
  s.clockVersion.fetch_add(1, std::memory_order_acq_rel);
  s.clockFrame.store(static_cast<int64_t>(ring->head()) - static_cast<int64_t>(delayFrames),
                     std::memory_order_relaxed);
  s.clockEpoch.store(s.epoch.load(std::memory_order_acquire), std::memory_order_relaxed);
  s.clockTimeNs.store(nowNs(), std::memory_order_relaxed);
  s.clockVersion.fetch_add(1, std::memory_order_release);
}

int AnalysisEngine::push(int id, const void* data, int frames, int encoding) {
  if (!running_.load(std::memory_order_acquire)) return 0;
  if (id < 0 || id >= NOXIRA_MAX_SOURCES || frames <= 0) return 0;
  Source& s = sources_[id];
  if (!s.inUse.load(std::memory_order_acquire)) return 0;
  StereoRing* ring = s.ring.load(std::memory_order_acquire);
  const int channels = s.channels.load(std::memory_order_relaxed);
  if (ring == nullptr || channels <= 0) return 0;

  const int64_t t0 = nowNs();
  pushPcm(*ring, data, frames, channels, encoding);
  const uint64_t cost = static_cast<uint64_t>(nowNs() - t0);
  pushCalls_.fetch_add(1, std::memory_order_relaxed);
  pushedFrames_.fetch_add(frames, std::memory_order_relaxed);
  pushNsTotal_.fetch_add(cost, std::memory_order_relaxed);
  atomicMax(pushNsMax_, cost);
  return frames;
}

// ------------------------------------------------------------ analysis thread

void AnalysisEngine::threadMain() {
  auto last = Clock::now();
  auto next = last;
  while (!stopRequested_.load(std::memory_order_acquire)) {
    const int rate = std::max(10, activeConfig_.analysis_rate_hz);
    const auto period = lastWasIdle_
                            ? std::chrono::duration_cast<Clock::duration>(kIdlePeriod)
                            : std::chrono::duration_cast<Clock::duration>(
                                  std::chrono::nanoseconds(1000000000LL / rate));
    next += period;
    const auto now = Clock::now();
    if (next < now) next = now;
    {
      std::unique_lock<std::mutex> lock(wakeMutex_);
      wakeCv_.wait_until(lock, next, [this] {
        return stopRequested_.load(std::memory_order_acquire) ||
               wake_.exchange(false, std::memory_order_acq_rel);
      });
    }
    if (stopRequested_.load(std::memory_order_acquire)) break;
    const auto tickStart = Clock::now();
    const double dt = std::chrono::duration<double>(tickStart - last).count();
    last = tickStart;
    tick(dt);
  }
}

void AnalysisEngine::publishMeta(NoxiraAudioFrame* frame, int state, int sampleRate,
                                 int channels, int64_t timestampUs) {
  frame->timestamp_us = timestampUs;
  frame->sequence = ++sequence_;
  frame->struct_size = sizeof(NoxiraAudioFrame);
  frame->abi_version = NOXIRA_ABI_VERSION;
  frame->state = state;
  frame->sample_rate = sampleRate;
  frame->source_channels = channels;
  frame->discontinuity_count = discontinuities_;
}

void AnalysisEngine::tick(double dt) {
  const int64_t cpu0 = threadCpuNs();
  const int64_t wall0 = nowNs();

  if (configDirty_.exchange(false, std::memory_order_acq_rel)) {
    std::lock_guard<std::mutex> lock(configMutex_);
    activeConfig_ = pendingConfig_;
    pipelineRate_ = 0.0f;  // forces a rebuild below
  }

  const int playback = playbackState_.load(std::memory_order_acquire);
  const bool playing = playback == NOXIRA_STATE_PLAYING;

  // The newest stream is the primary one; only sources with its sample rate
  // are mixed with it (e.g. the two players of a crossfade).
  int primary = -1;
  uint64_t bestOrder = 0;
  for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) {
    Source& s = sources_[i];
    if (!s.inUse.load(std::memory_order_acquire) || s.sampleRate.load(std::memory_order_relaxed) <= 0 ||
        s.ring.load(std::memory_order_acquire) == nullptr) {
      continue;
    }
    const uint64_t order = s.order.load(std::memory_order_relaxed);
    if (primary < 0 || order >= bestOrder) {
      primary = i;
      bestOrder = order;
    }
  }
  const int primaryRate = primary >= 0 ? sources_[primary].sampleRate.load(std::memory_order_relaxed) : 0;

  // Advance the playback cursor of every source of the primary rate.
  bool haveAudio = false;
  bool primaryEnded = false;
  int64_t timestampUs = 0;
  int channels = 0;
  const bool cfgRateChanged = pipelineRate_ != static_cast<float>(primaryRate > 0 ? primaryRate : 48000);
  if (cfgRateChanged || !pipeline_.configured()) {
    const float rate = static_cast<float>(primaryRate > 0 ? primaryRate : 48000);
    if (pipeline_.configure(activeConfig_, rate)) {
      pipelineRate_ = rate;
      const size_t n = static_cast<size_t>(pipeline_.windowSize());
      mixLeft_.assign(n, 0.0f);
      mixRight_.assign(n, 0.0f);
      tmpLeft_.assign(n, 0.0f);
      tmpRight_.assign(n, 0.0f);
    }
  }
  const int window = pipeline_.configured() ? pipeline_.windowSize() : 0;
  const int mixCapacity = static_cast<int>(mixLeft_.size());
  if (window > 0 && window <= mixCapacity) {
    std::fill(mixLeft_.begin(), mixLeft_.end(), 0.0f);
    std::fill(mixRight_.begin(), mixRight_.end(), 0.0f);
  }

  for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) {
    Source& s = sources_[i];
    Cursor& c = cursors_[i];
    if (!s.inUse.load(std::memory_order_acquire)) {
      c.valid = false;
      c.epochSeen = 0xFFFFFFFFu;
      continue;
    }
    StereoRing* ring = s.ring.load(std::memory_order_acquire);
    const int sr = s.sampleRate.load(std::memory_order_relaxed);
    if (ring == nullptr || sr <= 0) continue;

    const uint32_t epoch = s.epoch.load(std::memory_order_acquire);
    if (epoch != c.epochSeen) {
      if (c.epochSeen != 0xFFFFFFFFu && i == primary) pendingDiscontinuity_ = true;
      c.epochSeen = epoch;
      c.valid = false;
    }
    const uint64_t head = ring->head();
    const uint64_t start = s.streamStart.load(std::memory_order_acquire);
    if (!c.valid) {
      if (head <= start) continue;  // nothing of the new stream arrived yet
      const uint64_t lead = static_cast<uint64_t>(kInitialLeadSeconds * sr);
      // After a flush the stream starts exactly at `start`. When analysis was
      // switched on mid-stream, audible audio trails the newest data by the
      // player's buffer, which is estimated.
      c.position = s.exactStart.load(std::memory_order_acquire)
                       ? static_cast<double>(start)
                       : static_cast<double>(std::max(start, head > lead ? head - lead : 0));
      c.streamStart = start;
      c.valid = true;
    }
    if (playing) {
      const uint32_t version = s.clockVersion.load(std::memory_order_acquire);
      const int64_t clockTime = s.clockTimeNs.load(std::memory_order_relaxed);
      const int64_t clockFrame = s.clockFrame.load(std::memory_order_relaxed);
      const uint32_t clockEpoch = s.clockEpoch.load(std::memory_order_relaxed);
      const bool stable = !(version & 1) &&
          s.clockVersion.load(std::memory_order_acquire) == version;
      if (stable && clockTime > 0 && clockEpoch == epoch) {
        c.position = clockFrame + std::max<int64_t>(0, nowNs() - clockTime) * sr / 1e9;
      } else {
        c.position += dt * sr;
      }
    }
    if (c.position > static_cast<double>(head)) c.position = static_cast<double>(head);

    if (i == primary) {
      primaryEnded = s.ended.load(std::memory_order_acquire) != 0 &&
                     c.position >= static_cast<double>(head) - 1.0;
      timestampUs = static_cast<int64_t>(
          std::max(0.0, c.position - static_cast<double>(c.streamStart)) * 1e6 / sr);
      channels = s.channels.load(std::memory_order_relaxed);
    }

    if (sr != primaryRate || window == 0 || window > mixCapacity) continue;

    const int64_t latency =
        static_cast<int64_t>(activeConfig_.latency_compensation_ms * 0.001 * sr);
    int64_t end = static_cast<int64_t>(c.position) - latency;
    if (end < 0) end = 0;
    int pad = 0;
    uint64_t from = 0;
    if (end >= window) {
      from = static_cast<uint64_t>(end - window);
    } else {
      pad = window - static_cast<int>(end);
    }
    std::fill(tmpLeft_.begin(), tmpLeft_.begin() + pad, 0.0f);
    std::fill(tmpRight_.begin(), tmpRight_.begin() + pad, 0.0f);
    if (!ring->read(from, static_cast<uint32_t>(window - pad), c.streamStart,
                    tmpLeft_.data() + pad, tmpRight_.data() + pad)) {
      // The producer lapped the analysis (or the data is not there yet).
      if (head > static_cast<uint64_t>(end) + kRingFrames) {
        ringOverruns_.fetch_add(1, std::memory_order_relaxed);
        const uint64_t lead = static_cast<uint64_t>(kInitialLeadSeconds * sr);
        c.position = static_cast<double>(head > lead ? head - lead : 0);
      }
      continue;
    }
    for (int k = 0; k < window; ++k) {
      mixLeft_[k] += tmpLeft_[k];
      mixRight_[k] += tmpRight_[k];
    }
    haveAudio = true;
  }

  int state = playback;
  if (!haveAudio && playing) state = NOXIRA_STATE_WAITING;
  if (primaryEnded && playing) state = NOXIRA_STATE_ENDED;
  const bool process = haveAudio && playing && !primaryEnded && pipeline_.configured();

  if (pendingDiscontinuity_) {
    ++discontinuities_;
    pipeline_.softReset();
  }

  // Nothing audible and nothing left to decay: stay quiet until something changes.
  const bool alreadyQuiet = lastWasIdle_ && !process && state == lastPublishedState_ &&
                            !pendingDiscontinuity_;
  pendingDiscontinuity_ = false;
  if (alreadyQuiet) return;

  NoxiraAudioFrame* frame = frames_.back();
  if (process) {
    pipeline_.process(mixLeft_.data(), mixRight_.data(), dt, frame);
  } else {
    pipeline_.decay(dt, frame);
  }
  publishMeta(frame, state, primaryRate, channels, timestampUs);
  frames_.publish();
  lastPublishedState_ = state;
  lastWasIdle_ = !process && pipeline_.idle();
  framesPublished_.fetch_add(1, std::memory_order_relaxed);

  const int64_t wall1 = nowNs();
  const uint64_t cost = static_cast<uint64_t>(wall1 - wall0);
  processNsTotal_.fetch_add(cost, std::memory_order_relaxed);
  atomicMax(processNsMax_, cost);
  processedFrames_.fetch_add(1, std::memory_order_relaxed);
  cpuNsTotal_.fetch_add(threadCpuNs() - cpu0, std::memory_order_relaxed);

  if (NoxiraFrameCallback cb = callback_.load(std::memory_order_acquire)) cb(frame->sequence);
}

}  // namespace noxira
