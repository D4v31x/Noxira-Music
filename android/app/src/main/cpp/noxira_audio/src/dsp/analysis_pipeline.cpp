#include "analysis_pipeline.h"

#include <algorithm>
#include <cmath>
#include <cstring>

namespace noxira {

namespace {

constexpr float kBandGateSoftDb = 6.0f;
// Smoothed values below this are invisible and snap to exactly zero.
constexpr float kVisibleEpsilon = 1e-3f;

int nearestPowerOfTwo(int value, int lo, int hi) {
  value = std::min(std::max(value, lo), hi);
  int best = lo;
  for (int p = lo; p <= hi; p <<= 1) {
    if (std::abs(p - value) < std::abs(best - value)) best = p;
  }
  return best;
}

float gateFor(float rawDb, float floorDb) {
  return clamp01((rawDb - floorDb) / kBandGateSoftDb);
}

int hzToBin(float hz, float binHz, int maxBin) {
  return std::min(std::max(static_cast<int>(std::lround(hz / binHz)), 1), maxBin);
}

}  // namespace

void fillDefaultConfig(NoxiraConfig* out) {
  std::memset(out, 0, sizeof(*out));
  out->struct_size = sizeof(NoxiraConfig);
  out->fft_size = 2048;
  out->band_count = 64;
  out->analysis_rate_hz = 60;
  out->stereo_bands = 0;
  out->spectrum_bins = 512;
  out->waveform_size = 512;
  out->min_hz = 20.0f;
  out->max_hz = 20000.0f;
  const float edges[NOXIRA_REGION_EDGE_COUNT] = {20,   60,   250,  500,
                                                 2000, 4000, 8000, 20000};
  std::memcpy(out->region_edges_hz, edges, sizeof(edges));
  out->attack_ms = 40.0f;
  out->release_ms = 200.0f;
  out->peak_hold_ms = 400.0f;
  out->peak_decay_per_sec = 0.8f;
  out->noise_floor_db = -70.0f;
  out->dynamic_range_db = 48.0f;
  out->min_reference_db = -18.0f;
  out->normalization_release_db_per_sec = 2.5f;
  out->sensitivity_tilt_db_per_octave = 0.0f;
  out->onset_sensitivity = 0.5f;
  out->latency_compensation_ms = 0.0f;
  out->contrast = 1.0f;
  out->global_reference_mix = 1.0f;
  out->level_floor = 0.0f;
  out->normalization_attack_ms = 0.0f;
}

void sanitizeConfig(NoxiraConfig* c) {
  c->struct_size = sizeof(NoxiraConfig);
  c->fft_size = nearestPowerOfTwo(c->fft_size, 1024, 4096);
  c->band_count = (c->band_count <= 48) ? 32 : (c->band_count <= 96 ? 64 : 128);
  c->analysis_rate_hz = std::min(std::max(c->analysis_rate_hz, 10), 120);
  c->stereo_bands = c->stereo_bands != 0;
  c->visualizer_spectrum = c->visualizer_spectrum != 0;
  c->spectrum_bins =
      nearestPowerOfTwo(c->spectrum_bins, 32, std::min(NOXIRA_MAX_SPECTRUM, c->fft_size / 2));
  c->waveform_size = nearestPowerOfTwo(c->waveform_size, 32, NOXIRA_MAX_WAVEFORM);
  c->min_hz = clampf(c->min_hz, 10.0f, 2000.0f);
  c->max_hz = clampf(c->max_hz, c->min_hz * 2.0f, 24000.0f);
  bool ascending = true;
  for (int i = 0; i < NOXIRA_REGION_EDGE_COUNT; ++i) {
    if (!(c->region_edges_hz[i] > 0.0f)) ascending = false;
    if (i > 0 && !(c->region_edges_hz[i] > c->region_edges_hz[i - 1])) ascending = false;
  }
  if (!ascending) {
    NoxiraConfig d;
    fillDefaultConfig(&d);
    std::memcpy(c->region_edges_hz, d.region_edges_hz, sizeof(d.region_edges_hz));
  }
  c->attack_ms = clampf(c->attack_ms, 0.0f, 2000.0f);
  c->release_ms = clampf(c->release_ms, 0.0f, 5000.0f);
  c->peak_hold_ms = clampf(c->peak_hold_ms, 0.0f, 5000.0f);
  c->peak_decay_per_sec = clampf(c->peak_decay_per_sec, 0.01f, 20.0f);
  c->noise_floor_db = clampf(c->noise_floor_db, -120.0f, -20.0f);
  c->dynamic_range_db = clampf(c->dynamic_range_db, 12.0f, 96.0f);
  c->min_reference_db = clampf(c->min_reference_db, -100.0f, 0.0f);
  c->normalization_release_db_per_sec =
      clampf(c->normalization_release_db_per_sec, 0.0f, 60.0f);
  c->sensitivity_tilt_db_per_octave = clampf(c->sensitivity_tilt_db_per_octave, -12.0f, 12.0f);
  for (int i = 0; i < NOXIRA_MAX_BANDS; ++i) {
    c->band_sensitivity_db[i] = clampf(c->band_sensitivity_db[i], -40.0f, 40.0f);
  }
  c->onset_sensitivity = clamp01(c->onset_sensitivity);
  c->latency_compensation_ms = clampf(c->latency_compensation_ms, 0.0f, 1000.0f);
  c->contrast = clampf(c->contrast, 0.5f, 4.0f);
  c->global_reference_mix = clamp01(c->global_reference_mix);
  c->level_floor = clampf(c->level_floor, 0.0f, 0.9f);
  c->normalization_attack_ms = clampf(c->normalization_attack_ms, 0.0f, 5000.0f);
}

AnalysisPipeline::AnalysisPipeline() { fillDefaultConfig(&config_); }

bool AnalysisPipeline::configure(const NoxiraConfig& config, float sampleRate) {
  configured_ = false;
  if (sampleRate < 8000.0f || sampleRate > 384000.0f) return false;
  config_ = config;
  sanitizeConfig(&config_);
  sampleRate_ = sampleRate;

  const int n = config_.fft_size;
  bins_ = n / 2 + 1;
  bandCount_ = config_.band_count;
  if (!fftLeft_.configure(n) || !fftRight_.configure(n)) return false;

  bandMapper_.configure(bandCount_, n, sampleRate_, config_.min_hz, config_.max_hz);
  regionMapper_.configure(config_.region_edges_hz, NOXIRA_REGION_COUNT, n, sampleRate_);
  bandNorm_.configure(bandCount_, config_.dynamic_range_db, config_.min_reference_db,
                      config_.normalization_release_db_per_sec,
                      config_.global_reference_mix,
                      config_.normalization_attack_ms * 0.001f);
  regionNorm_.configure(NOXIRA_REGION_COUNT, config_.dynamic_range_db,
                        config_.min_reference_db, config_.normalization_release_db_per_sec,
                        std::max(0.6f, config_.global_reference_mix),
                        config_.normalization_attack_ms * 0.001f);
  energyNorm_.configure(1, config_.dynamic_range_db, config_.min_reference_db,
                        config_.normalization_release_db_per_sec, 0.0f);

  spectrumCount_ = std::min(config_.spectrum_bins, n / 2);
  spectrumGroup_ = (n / 2) / spectrumCount_;
  waveformCount_ = std::min(config_.waveform_size, n);
  waveformGroup_ = n / waveformCount_;

  auto zeros = [](std::vector<float>& v, int size) { v.assign(static_cast<size_t>(size), 0.0f); };
  zeros(magMono_, bins_);
  zeros(magLeft_, bins_);
  zeros(magRight_, bins_);
  zeros(bandLin_, bandCount_);
  zeros(bandDb_, bandCount_);
  zeros(bandNormOut_, bandCount_);
  zeros(bandGate_, bandCount_);
  zeros(bandLinL_, bandCount_);
  zeros(bandDbL_, bandCount_);
  zeros(bandNormL_, bandCount_);
  zeros(bandGateL_, bandCount_);
  zeros(bandLinR_, bandCount_);
  zeros(bandDbR_, bandCount_);
  zeros(bandNormR_, bandCount_);
  zeros(bandGateR_, bandCount_);
  zeros(regionLin_, NOXIRA_REGION_COUNT);
  zeros(regionDb_, NOXIRA_REGION_COUNT);
  zeros(regionNormOut_, NOXIRA_REGION_COUNT);
  zeros(regionGate_, NOXIRA_REGION_COUNT);
  zeros(spectrumDb_, spectrumCount_);
  zeros(spectrumTarget_, spectrumCount_);
  zeros(compressed_, bins_);
  zeros(prevCompressed_, bins_);
  zeros(compressedBands_, bandCount_);
  zeros(prevBands_, bandCount_);
  zeros(bandSmooth_, bandCount_);
  zeros(bandSmoothL_, bandCount_);
  zeros(bandSmoothR_, bandCount_);
  zeros(bandPeak_, bandCount_);
  zeros(bandPeakTimer_, bandCount_);
  zeros(regionSmooth_, NOXIRA_REGION_COUNT);
  zeros(regionPeak_, NOXIRA_REGION_COUNT);
  zeros(regionPeakTimer_, NOXIRA_REGION_COUNT);
  zeros(spectrumSmooth_, spectrumCount_);
  tilt_.assign(static_cast<size_t>(bandCount_), 0.0f);
  for (int i = 0; i < bandCount_; ++i) {
    tilt_[i] = config_.sensitivity_tilt_db_per_octave *
                   std::log2(bandMapper_.centerHz(i) / 1000.0f) +
               config_.band_sensitivity_db[i];
  }

  const float binHz = sampleRate_ / static_cast<float>(n);
  const int maxBin = bins_ - 2;
  const float nyq = sampleRate_ * 0.5f * 0.98f;
  kickLo_ = hzToBin(30.0f, binHz, maxBin);
  kickHi_ = std::max(kickLo_, hzToBin(120.0f, binHz, maxBin));
  beatLo_ = hzToBin(30.0f, binHz, maxBin);
  beatHi_ = std::max(beatLo_, hzToBin(150.0f, binHz, maxBin));
  snareLowLo_ = hzToBin(150.0f, binHz, maxBin);
  snareLowHi_ = std::max(snareLowLo_, hzToBin(350.0f, binHz, maxBin));
  snareHighLo_ = hzToBin(1500.0f, binHz, maxBin);
  snareHighHi_ = std::max(snareHighLo_, hzToBin(std::min(6000.0f, nyq), binHz, maxBin));
  hatLo_ = hzToBin(6000.0f, binHz, maxBin);
  hatHi_ = std::max(hatLo_, hzToBin(std::min(16000.0f, nyq), binHz, maxBin));

  const float rate = static_cast<float>(config_.analysis_rate_hz);
  const float s = config_.onset_sensitivity;
  onsetAll_.configure(rate, 0.7f, 0.06f, 0.015f, s);
  onsetKick_.configure(rate, 0.7f, 0.09f, 0.05f, s);
  onsetSnare_.configure(rate, 0.7f, 0.10f, 0.15f, s);
  onsetHat_.configure(rate, 0.7f, 0.05f, 0.04f, s);
  onsetBeat_.configure(rate, 0.7f, 0.27f, 0.05f, s);

  configured_ = true;
  reset();
  return true;
}

void AnalysisPipeline::reset() {
  bandNorm_.reset();
  regionNorm_.reset();
  energyNorm_.reset();
  for (auto* v : {&bandSmooth_, &bandSmoothL_, &bandSmoothR_, &bandPeak_, &bandPeakTimer_,
                  &regionSmooth_, &regionPeak_, &regionPeakTimer_, &spectrumSmooth_,
                  &prevCompressed_, &prevBands_}) {
    std::fill(v->begin(), v->end(), 0.0f);
  }
  energySmooth_ = 0.0f;
  peakHold_ = peakHoldTimer_ = 0.0f;
  onsetAll_.reset();
  onsetKick_.reset();
  onsetSnare_.reset();
  onsetHat_.reset();
  onsetBeat_.reset();
  fluxRunMax_ = kickRunMax_ = snareLowRunMax_ = snareHighRunMax_ = hatRunMax_ = 0.05f;
  fluxOut_ = transientOut_ = kickAct_ = snareAct_ = hatAct_ = 0.0f;
  slowRms_ = 0.0f;
  centroidHz_ = 0.0f;
  widthS_ = balanceS_ = 0.0f;
  corrS_ = 1.0f;
  beatConfidence_ = bpm_ = 0.0f;
  sinceBeat_ = 1e6;
  beatClock_ = 0.0;
  lastBeatTime_ = -1.0;
  intervalCount_ = intervalHead_ = 0;
  havePrev_ = false;
  skipFlux_ = 0;
  idle_ = true;
}

void AnalysisPipeline::softReset() {
  havePrev_ = false;
  skipFlux_ = 2;
  lastBeatTime_ = -1.0;
}

float AnalysisPipeline::groupFlux(int firstBin, int lastBin) const {
  float sum = 0.0f;
  for (int k = firstBin; k <= lastBin; ++k) {
    const float d = compressed_[k] - prevCompressed_[k];
    if (d > 0.0f) sum += d;
  }
  return sum / static_cast<float>(lastBin - firstBin + 1);
}

void AnalysisPipeline::applyContrast(std::vector<float>& values) const {
  const float c = config_.contrast;
  const float floor = config_.level_floor;
  if (c == 1.0f && floor == 0.0f) return;
  const float scale = 1.0f / (1.0f - floor);
  for (float& v : values) {
    const float x = (v - floor) * scale;
    v = x > 0.0f ? std::pow(x, c) : 0.0f;
  }
}

void AnalysisPipeline::updateBandOutputs(float dt, bool stereo) {
  const float floorDb = config_.noise_floor_db;
  auto levels = [&](const std::vector<float>& linear, std::vector<float>& db,
                    std::vector<float>& gate) {
    for (int i = 0; i < bandCount_; ++i) {
      const float raw = amplitudeToDb(linear[i]);
      gate[i] = gateFor(raw, floorDb);
      db[i] = raw < floorDb ? kSilenceDb : raw + tilt_[i];
    }
  };
  levels(bandLin_, bandDb_, bandGate_);
  bandNorm_.process(bandDb_.data(), bandNormOut_.data(), dt);
  for (int i = 0; i < bandCount_; ++i) bandNormOut_[i] *= bandGate_[i];
  applyContrast(bandNormOut_);
  if (stereo) {
    levels(bandLinL_, bandDbL_, bandGateL_);
    levels(bandLinR_, bandDbR_, bandGateR_);
    bandNorm_.apply(bandDbL_.data(), bandNormL_.data());
    bandNorm_.apply(bandDbR_.data(), bandNormR_.data());
    for (int i = 0; i < bandCount_; ++i) {
      bandNormL_[i] *= bandGateL_[i];
      bandNormR_[i] *= bandGateR_[i];
    }
    applyContrast(bandNormL_);
    applyContrast(bandNormR_);
  } else {
    std::copy(bandNormOut_.begin(), bandNormOut_.end(), bandNormL_.begin());
    std::copy(bandNormOut_.begin(), bandNormOut_.end(), bandNormR_.begin());
  }
}

void AnalysisPipeline::clearTargets() {
  std::fill(bandNormOut_.begin(), bandNormOut_.end(), 0.0f);
  std::fill(bandNormL_.begin(), bandNormL_.end(), 0.0f);
  std::fill(bandNormR_.begin(), bandNormR_.end(), 0.0f);
  std::fill(regionNormOut_.begin(), regionNormOut_.end(), 0.0f);
  std::fill(spectrumTarget_.begin(), spectrumTarget_.end(), 0.0f);
  targetEnergy_ = 0.0f;
  evOnset_ = evBeat_ = evKick_ = evSnare_ = evHat_ = false;
  onsetStrength_ = kickStrength_ = snareStrength_ = hatStrength_ = 0.0f;
  rmsMono_ = peakMono_ = rmsL_ = rmsR_ = peakL_ = peakR_ = zcr_ = 0.0f;
  fluxRaw_ = transientRaw_ = 0.0f;
  stereoWidth_ = 0.0f;
  stereoCorr_ = 1.0f;
  stereoBalance_ = 0.0f;
}

void AnalysisPipeline::process(const float* left, const float* right, double dt,
                               NoxiraAudioFrame* out) {
  if (!configured_) return;
  const float fdt = static_cast<float>(std::min(std::max(dt, 0.001), 0.25));
  const int n = config_.fft_size;
  const int levelN = std::min(n, 1024);
  const int off = n - levelN;

  // ---- time-domain measurements on the most recent ~21 ms ----
  double sumLL = 0, sumRR = 0, sumLR = 0, sumMid = 0, sumSide = 0;
  float peakL = 0, peakR = 0;
  int crossingsL = 0, crossingsR = 0;
  float signL = 0.0f, signR = 0.0f;
  for (int i = off; i < n; ++i) {
    const float l = left[i], r = right[i];
    sumLL += static_cast<double>(l) * l;
    sumRR += static_cast<double>(r) * r;
    sumLR += static_cast<double>(l) * r;
    const float mid = 0.5f * (l + r), side = 0.5f * (l - r);
    sumMid += static_cast<double>(mid) * mid;
    sumSide += static_cast<double>(side) * side;
    peakL = std::max(peakL, std::fabs(l));
    peakR = std::max(peakR, std::fabs(r));
    const float sl = l >= 0.0f ? 1.0f : -1.0f, sr = r >= 0.0f ? 1.0f : -1.0f;
    if (i > off) {
      if (sl != signL) ++crossingsL;
      if (sr != signR) ++crossingsR;
    }
    signL = sl;
    signR = sr;
  }
  const double invN = 1.0 / levelN;
  const float rmsL = static_cast<float>(std::sqrt(sumLL * invN));
  const float rmsR = static_cast<float>(std::sqrt(sumRR * invN));
  // Level of both channels together (power average), so content that only
  // exists in the side channel (out of phase) is still audible.
  const float rmsM = static_cast<float>(std::sqrt(0.5 * (sumLL + sumRR) * invN));
  const float peakM = std::max(peakL, peakR);

  // Silence is judged over the whole analysis window, not just the newest
  // 21 ms: a short transient is still inside the FFT window for a few frames.
  double windowEnergy = 0.0;
  for (int i = 0; i < n; ++i) {
    windowEnergy += static_cast<double>(left[i]) * left[i] + static_cast<double>(right[i]) * right[i];
  }
  const float windowRms = static_cast<float>(std::sqrt(0.5 * windowEnergy / n));
  const float floorAmp = std::pow(10.0f, config_.noise_floor_db / 20.0f);
  if (!(windowRms > floorAmp) || !std::isfinite(windowRms)) {
    decay(dt, out);
    return;
  }

  clearTargets();
  rmsMono_ = rmsM;
  peakMono_ = peakM;
  rmsL_ = rmsL;
  rmsR_ = rmsR;
  peakL_ = peakL;
  peakR_ = peakR;
  zcr_ = levelN > 1 ? 0.5f * static_cast<float>(crossingsL + crossingsR) /
                          static_cast<float>(levelN - 1)
                    : 0.0f;
  {
    // One silent channel has no defined correlation; report 0 (uncorrelated).
    const double denom = std::sqrt(sumLL * sumRR);
    const bool oneSided = std::min(sumLL, sumRR) < 1e-6 * std::max(sumLL, sumRR);
    stereoCorr_ = (denom > 1e-12 && !oneSided) ? static_cast<float>(sumLR / denom) : 0.0f;
    stereoCorr_ = clampf(stereoCorr_, -1.0f, 1.0f);
    const double mid = std::sqrt(sumMid), side = std::sqrt(sumSide);
    stereoWidth_ = static_cast<float>(side / (mid + side + 1e-12));
    stereoBalance_ = static_cast<float>((rmsR - rmsL) / (rmsR + rmsL + 1e-12));
  }

  // ---- spectrum ----
  fftLeft_.amplitudeSpectrum(left, magLeft_.data());
  fftRight_.amplitudeSpectrum(right, magRight_.data());
  // Combined spectrum: power average of the channels (no phase cancellation).
  for (int k = 0; k < bins_; ++k) {
    magMono_[k] = std::sqrt(0.5f * (magLeft_[k] * magLeft_[k] + magRight_[k] * magRight_[k]));
  }
  bandMapper_.map(magMono_.data(), bandLin_.data());
  const bool stereoBands = config_.stereo_bands != 0;
  if (stereoBands) {
    bandMapper_.map(magLeft_.data(), bandLinL_.data());
    bandMapper_.map(magRight_.data(), bandLinR_.data());
  }

  const float floorDb = config_.noise_floor_db;
  updateBandOutputs(fdt, stereoBands);

  // Regions.
  regionMapper_.map(magMono_.data(), regionLin_.data());
  for (int i = 0; i < NOXIRA_REGION_COUNT; ++i) {
    const float raw = amplitudeToDb(regionLin_[i]);
    regionGate_[i] = gateFor(raw, floorDb);
    regionDb_[i] = raw < floorDb ? kSilenceDb : raw;
  }
  regionNorm_.process(regionDb_.data(), regionNormOut_.data(), fdt);
  for (int i = 0; i < NOXIRA_REGION_COUNT; ++i) regionNormOut_[i] *= regionGate_[i];
  applyContrast(regionNormOut_);

  // Exported linear-frequency spectrum, max-pooled to spectrumCount_ entries.
  {
    const float ref = bandNorm_.globalReferenceDb();
    const float range = bandNorm_.rangeDb();
    for (int j = 0; j < spectrumCount_; ++j) {
      float m = 0.0f;
      const int first = 1 + j * spectrumGroup_;
      for (int g = 0; g < spectrumGroup_; ++g) m = std::max(m, magMono_[first + g]);
      const float raw = amplitudeToDb(m);
      spectrumTarget_[j] =
          raw < floorDb ? 0.0f : clamp01((raw - (ref - range)) / range) * gateFor(raw, floorDb);
    }
    applyContrast(spectrumTarget_);
  }

  // Overall energy from the RMS level.
  {
    const float db = amplitudeToDb(rmsM);
    float x = 0.0f;
    energyNorm_.process(&db, &x, fdt);
    targetEnergy_ = x;
  }

  // Spectral centroid.
  {
    const float binHz = sampleRate_ / static_cast<float>(n);
    double num = 0.0, den = 0.0;
    for (int k = 1; k < bins_ - 1; ++k) {
      num += static_cast<double>(k) * binHz * magMono_[k];
      den += magMono_[k];
    }
    const float c = den > 1e-9 ? static_cast<float>(num / den) : 0.0f;
    centroidHz_ = attackRelease(centroidHz_, c, fdt, 0.05f, 0.12f);
  }

  // ---- spectral flux, onsets, percussion ----
  // Full-band flux is measured on the log-spaced bands, so a bass hit and a
  // hi-hat weigh the same instead of the many high FFT bins drowning the bass.
  for (int k = 1; k < bins_ - 1; ++k) compressed_[k] = std::log10(1.0f + 100.0f * magMono_[k]);
  for (int i = 0; i < bandCount_; ++i) compressedBands_[i] = std::log10(1.0f + 100.0f * bandLin_[i]);
  float kickF = 0, snareLowF = 0, snareHighF = 0, hatF = 0, beatF = 0, fluxF = 0;
  if (havePrev_ && skipFlux_ == 0) {
    for (int i = 0; i < bandCount_; ++i) {
      const float d = compressedBands_[i] - prevBands_[i];
      if (d > 0.0f) fluxF += d;
    }
    fluxF /= static_cast<float>(bandCount_);
    kickF = groupFlux(kickLo_, kickHi_);
    beatF = groupFlux(beatLo_, beatHi_);
    snareLowF = groupFlux(snareLowLo_, snareLowHi_);
    snareHighF = groupFlux(snareHighLo_, snareHighHi_);
    hatF = groupFlux(hatLo_, hatHi_);
    // Low-end energy that is merely leakage from a louder body just above
    // (snare, toms) must not look like a kick.
    kickF = std::max(0.0f, kickF - 0.5f * snareLowF);
    beatF = std::max(0.0f, beatF - 0.5f * snareLowF);
  } else if (skipFlux_ > 0) {
    --skipFlux_;
  }
  std::copy(compressed_.begin() + 1, compressed_.begin() + (bins_ - 1),
            prevCompressed_.begin() + 1);
  std::copy(compressedBands_.begin(), compressedBands_.end(), prevBands_.begin());
  havePrev_ = true;

  auto follow = [&](float& runMax, float v) {
    runMax = std::max(v, runMax * std::exp(-fdt / 3.0f));
    runMax = std::max(runMax, 0.03f);
    return v / runMax;
  };
  fluxRaw_ = clamp01(follow(fluxRunMax_, fluxF));
  follow(kickRunMax_, kickF);
  const float snareLowN = follow(snareLowRunMax_, snareLowF);
  const float snareHighN = follow(snareHighRunMax_, snareHighF);
  follow(hatRunMax_, hatF);

  const auto onset = onsetAll_.update(fluxF, fdt);
  const auto kick = onsetKick_.update(kickF, fdt);
  const auto snare = onsetSnare_.update(std::sqrt(snareLowN * snareHighN), fdt);
  const auto hat = onsetHat_.update(hatF, fdt);
  const auto beat = onsetBeat_.update(beatF, fdt);
  evOnset_ = onset.triggered;
  onsetStrength_ = onset.triggered ? onset.strength : 0.0f;
  evKick_ = kick.triggered;
  kickStrength_ = kick.strength;
  evSnare_ = snare.triggered;
  snareStrength_ = snare.strength;
  evHat_ = hat.triggered;
  hatStrength_ = hat.strength;

  // Beat clock and tempo estimate from inter-beat intervals.
  beatClock_ += fdt;
  sinceBeat_ += fdt;
  if (beat.triggered) {
    evBeat_ = true;
    if (lastBeatTime_ >= 0.0) {
      const double ibi = beatClock_ - lastBeatTime_;
      if (ibi >= 0.3 && ibi <= 1.5) {
        intervals_[intervalHead_] = static_cast<float>(ibi);
        intervalHead_ = (intervalHead_ + 1) % 16;
        intervalCount_ = std::min(intervalCount_ + 1, 16);
      }
    }
    lastBeatTime_ = beatClock_;
    sinceBeat_ = 0.0;
  }
  if (intervalCount_ >= 3) {
    float sorted[16];
    std::copy(intervals_, intervals_ + intervalCount_, sorted);
    std::sort(sorted, sorted + intervalCount_);
    const float median = sorted[intervalCount_ / 2];
    int close = 0;
    for (int i = 0; i < intervalCount_; ++i) {
      if (std::fabs(sorted[i] - median) <= 0.1f * median) ++close;
    }
    bpm_ = 60.0f / median;
    beatConfidence_ = static_cast<float>(close) / static_cast<float>(intervalCount_);
  }
  if (sinceBeat_ > 4.0) {
    bpm_ = 0.0f;
    beatConfidence_ = 0.0f;
    intervalCount_ = 0;
  }

  // Transient: how far the fast level is above its slow average.
  {
    const float rise = rmsM / std::max(slowRms_, 1e-5f);
    transientRaw_ = std::max(clamp01((rise - 1.0f) / 2.0f), 0.7f * fluxRaw_);
    slowRms_ += (rmsM - slowRms_) * smoothingAlpha(fdt, 0.12f);
  }

  finish(dt, out, false);
  if (config_.visualizer_spectrum) {
    visualizerSpectrum(magMono_.data(), left, right, n, out->visualizer_spectrum);
  }

  // Waveform: peak-preserving decimation of the analysed window.
  for (int j = 0; j < waveformCount_; ++j) {
    float bestL = 0.0f, bestR = 0.0f;
    const int base = j * waveformGroup_;
    for (int g = 0; g < waveformGroup_; ++g) {
      if (std::fabs(left[base + g]) > std::fabs(bestL)) bestL = left[base + g];
      if (std::fabs(right[base + g]) > std::fabs(bestR)) bestR = right[base + g];
    }
    out->waveform_left[j] = clampf(bestL, -1.0f, 1.0f);
    out->waveform_right[j] = clampf(bestR, -1.0f, 1.0f);
  }
}

void AnalysisPipeline::decay(double dt, NoxiraAudioFrame* out) {
  if (!configured_) return;
  clearTargets();
  // The spectrum is silent: the next sound starts from a zero spectrum, so
  // its first frame is a proper onset.
  std::fill(prevCompressed_.begin(), prevCompressed_.end(), 0.0f);
  std::fill(prevBands_.begin(), prevBands_.end(), 0.0f);
  havePrev_ = true;
  // Time keeps running during silence: refractory periods, the onset history
  // and the beat clock must not stall, or gaps would skew tempo and re-arm
  // detectors late.
  const float fdt = static_cast<float>(std::min(std::max(dt, 0.001), 0.25));
  onsetAll_.update(0.0f, fdt);
  onsetKick_.update(0.0f, fdt);
  onsetSnare_.update(0.0f, fdt);
  onsetHat_.update(0.0f, fdt);
  onsetBeat_.update(0.0f, fdt);
  beatClock_ += fdt;
  sinceBeat_ += fdt;
  if (sinceBeat_ > 4.0) {
    bpm_ = 0.0f;
    beatConfidence_ = 0.0f;
    intervalCount_ = 0;
  }
  finish(dt, out, true);
}

void AnalysisPipeline::finish(double dt, NoxiraAudioFrame* out, bool silent) {
  const float fdt = static_cast<float>(std::min(std::max(dt, 0.001), 0.25));
  const float atk = config_.attack_ms * 0.001f;
  const float rel = config_.release_ms * 0.001f;
  const float hold = config_.peak_hold_ms * 0.001f;
  const float peakDecay = config_.peak_decay_per_sec;
  float activity = 0.0f;  // largest remaining output, for idle detection

  auto holdPeak = [&](float value, float& peak, float& timer) {
    if (value >= peak) {
      peak = value;
      timer = hold;
    } else if (timer > 0.0f) {
      timer -= fdt;
    } else {
      peak = std::max(value, peak - peakDecay * fdt);
    }
  };

  // ---- 1. advance all smoothed state towards this frame's targets ----
  for (int i = 0; i < bandCount_; ++i) {
    bandSmooth_[i] = attackRelease(bandSmooth_[i], bandNormOut_[i], fdt, atk, rel);
    bandSmoothL_[i] = attackRelease(bandSmoothL_[i], bandNormL_[i], fdt, atk, rel);
    bandSmoothR_[i] = attackRelease(bandSmoothR_[i], bandNormR_[i], fdt, atk, rel);
    if (bandSmooth_[i] < kVisibleEpsilon) bandSmooth_[i] = 0.0f;
    if (bandSmoothL_[i] < kVisibleEpsilon) bandSmoothL_[i] = 0.0f;
    if (bandSmoothR_[i] < kVisibleEpsilon) bandSmoothR_[i] = 0.0f;
    holdPeak(bandSmooth_[i], bandPeak_[i], bandPeakTimer_[i]);
    activity = std::max({activity, bandSmooth_[i], bandSmoothL_[i], bandSmoothR_[i], bandPeak_[i]});
  }
  for (int i = 0; i < NOXIRA_REGION_COUNT; ++i) {
    regionSmooth_[i] = attackRelease(regionSmooth_[i], regionNormOut_[i], fdt, atk, rel);
    if (regionSmooth_[i] < kVisibleEpsilon) regionSmooth_[i] = 0.0f;
    holdPeak(regionSmooth_[i], regionPeak_[i], regionPeakTimer_[i]);
    activity = std::max({activity, regionSmooth_[i], regionPeak_[i]});
  }
  for (int j = 0; j < spectrumCount_; ++j) {
    spectrumSmooth_[j] = attackRelease(spectrumSmooth_[j], spectrumTarget_[j], fdt, atk, rel);
    if (spectrumSmooth_[j] < kVisibleEpsilon) spectrumSmooth_[j] = 0.0f;
    activity = std::max(activity, spectrumSmooth_[j]);
  }
  energySmooth_ = attackRelease(energySmooth_, targetEnergy_, fdt, atk, rel);
  if (energySmooth_ < kVisibleEpsilon) energySmooth_ = 0.0f;
  fluxOut_ = attackRelease(fluxOut_, fluxRaw_, fdt, 0.0f, 0.1f);
  transientOut_ = attackRelease(transientOut_, transientRaw_, fdt, 0.0f, 0.09f);
  activity = std::max({activity, energySmooth_, fluxOut_, transientOut_});

  // Percussion activity: jump on a hit, then decay.
  auto act = [&](float& value, bool hit, float strength, float tau) {
    value *= std::exp(-fdt / tau);
    if (hit) value = std::max(value, 0.4f + 0.6f * strength);
    activity = std::max(activity, value);
  };
  act(kickAct_, evKick_, kickStrength_, 0.14f);
  act(snareAct_, evSnare_, snareStrength_, 0.11f);
  act(hatAct_, evHat_, hatStrength_, 0.05f);

  widthS_ = attackRelease(widthS_, stereoWidth_, fdt, 0.08f, 0.08f);
  corrS_ = attackRelease(corrS_, stereoCorr_, fdt, 0.08f, 0.08f);
  balanceS_ = attackRelease(balanceS_, stereoBalance_, fdt, 0.08f, 0.08f);

  peakHoldTimer_ -= fdt;
  if (peakMono_ >= peakHold_) {
    peakHold_ = peakMono_;
    peakHoldTimer_ = hold;
  } else if (peakHoldTimer_ <= 0.0f) {
    peakHold_ = std::max(peakMono_, peakHold_ - 1.5f * fdt);
  }

  // ---- 2. once silent and (almost) faded out, snap to exactly zero ----
  idle_ = silent && activity < 2e-3f && peakHold_ < 1e-3f;
  if (idle_) {
    for (auto* v : {&bandSmooth_, &bandSmoothL_, &bandSmoothR_, &bandPeak_, &bandPeakTimer_,
                    &regionSmooth_, &regionPeak_, &regionPeakTimer_, &spectrumSmooth_}) {
      std::fill(v->begin(), v->end(), 0.0f);
    }
    energySmooth_ = fluxOut_ = transientOut_ = 0.0f;
    kickAct_ = snareAct_ = hatAct_ = 0.0f;
    peakHold_ = 0.0f;
  }

  // ---- 3. write the frame ----
  std::memset(out->bands, 0, sizeof(out->bands));
  std::memset(out->bands_left, 0, sizeof(out->bands_left));
  std::memset(out->bands_right, 0, sizeof(out->bands_right));
  std::memset(out->band_peaks, 0, sizeof(out->band_peaks));
  std::memset(out->spectrum, 0, sizeof(out->spectrum));
  std::memset(out->waveform_left, 0, sizeof(out->waveform_left));
  std::memset(out->waveform_right, 0, sizeof(out->waveform_right));
  std::memset(out->visualizer_spectrum, 0, sizeof(out->visualizer_spectrum));
  std::memset(out->regions, 0, sizeof(out->regions));
  std::memset(out->region_peaks, 0, sizeof(out->region_peaks));
  for (int i = 0; i < bandCount_; ++i) {
    out->bands[i] = bandSmooth_[i];
    out->bands_left[i] = bandSmoothL_[i];
    out->bands_right[i] = bandSmoothR_[i];
    out->band_peaks[i] = bandPeak_[i];
  }
  for (int i = 0; i < NOXIRA_REGION_COUNT; ++i) {
    out->regions[i] = regionSmooth_[i];
    out->region_peaks[i] = regionPeak_[i];
  }
  for (int j = 0; j < spectrumCount_; ++j) out->spectrum[j] = spectrumSmooth_[j];

  out->fft_size = config_.fft_size;
  out->band_count = bandCount_;
  out->spectrum_count = spectrumCount_;
  out->waveform_count = waveformCount_;
  out->visualizer_spectrum_count = config_.visualizer_spectrum ? config_.fft_size / 2 : 0;
  out->sample_rate = static_cast<int32_t>(sampleRate_);
  out->rms = rmsMono_;
  out->peak = peakMono_;
  out->peak_hold = peakHold_;
  out->energy = energySmooth_;
  out->centroid_hz = silent ? 0.0f : centroidHz_;
  out->centroid = (silent || centroidHz_ < 20.0f)
                      ? 0.0f
                      : clamp01(std::log10(centroidHz_ / 20.0f) / 3.0f);
  out->flux = fluxOut_;
  out->zero_crossing_rate = zcr_;
  out->transient = transientOut_;
  out->onset_strength = onsetStrength_;
  out->beat_confidence = beatConfidence_;
  out->bpm = bpm_;
  out->kick = kickAct_;
  out->snare = snareAct_;
  out->hihat = hatAct_;
  out->percussion = std::max({kickAct_, snareAct_, hatAct_});
  out->bass_activity = std::max(regionSmooth_[0], regionSmooth_[1]);
  out->stereo_width = widthS_;
  out->stereo_correlation = corrS_;
  out->stereo_balance = balanceS_;
  out->rms_left = rmsL_;
  out->rms_right = rmsR_;
  out->peak_left = peakL_;
  out->peak_right = peakR_;

  int flags = silent ? NOXIRA_FLAG_SILENT : 0;
  if (evOnset_) flags |= NOXIRA_FLAG_ONSET;
  if (evBeat_) flags |= NOXIRA_FLAG_BEAT;
  if (evKick_) flags |= NOXIRA_FLAG_KICK;
  if (evSnare_) flags |= NOXIRA_FLAG_SNARE;
  if (evHat_) flags |= NOXIRA_FLAG_HIHAT;
  out->flags = flags;
}

}  // namespace noxira
