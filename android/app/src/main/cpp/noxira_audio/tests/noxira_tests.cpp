// Host unit tests for the Noxira audio analysis engine (no framework needed).
//
//   cmake -S android/app/src/main/cpp -B build/noxira_host -DNOXIRA_BUILD_TESTS=ON
//   cmake --build build/noxira_host && ctest --test-dir build/noxira_host --output-on-failure
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <random>
#include <thread>
#include <vector>

#include "dsp/analysis_pipeline.h"
#include "dsp/band_mapper.h"
#include "dsp/pcm_convert.h"
#include "dsp/real_fft.h"
#include "dsp/stereo_ring.h"
#include "dsp/visualizer_spectrum.h"
#include "engine/triple_buffer.h"
#include "noxira_audio/noxira_audio.h"

using namespace noxira;

namespace {

int g_failures = 0;
int g_checks = 0;
const char* g_current = "";

#define CHECK(cond)                                                              \
  do {                                                                           \
    ++g_checks;                                                                  \
    if (!(cond)) {                                                               \
      ++g_failures;                                                              \
      std::printf("  FAIL [%s] %s:%d: %s\n", g_current, __FILE__, __LINE__, #cond); \
    }                                                                            \
  } while (0)

#define CHECK_NEAR(actual, expected, tol)                                                \
  do {                                                                                   \
    ++g_checks;                                                                          \
    const double a_ = (actual), e_ = (expected);                                         \
    if (!(std::fabs(a_ - e_) <= (tol))) {                                                \
      ++g_failures;                                                                      \
      std::printf("  FAIL [%s] %s:%d: %s = %g, expected %g +- %g\n", g_current, __FILE__, \
                  __LINE__, #actual, a_, e_, static_cast<double>(tol));                  \
    }                                                                                    \
  } while (0)

constexpr double kTwoPi = 6.283185307179586;

// ------------------------------------------------------------- signal helpers

struct Signal {
  std::vector<float> left, right;
  int sampleRate = 48000;
  size_t size() const { return left.size(); }
};

Signal makeSignal(double seconds, int sampleRate = 48000) {
  Signal s;
  s.sampleRate = sampleRate;
  const size_t n = static_cast<size_t>(seconds * sampleRate);
  s.left.assign(n, 0.0f);
  s.right.assign(n, 0.0f);
  return s;
}

void addSine(Signal& s, double hz, double amp, double phase = 0.0, bool l = true, bool r = true,
             size_t from = 0, size_t to = SIZE_MAX) {
  to = std::min(to, s.size());
  for (size_t i = from; i < to; ++i) {
    const float v = static_cast<float>(amp * std::sin(kTwoPi * hz * i / s.sampleRate + phase));
    if (l) s.left[i] += v;
    if (r) s.right[i] += v;
  }
}

NoxiraConfig makeConfig(int fft = 2048, int bands = 64, int rate = 60) {
  NoxiraConfig c;
  fillDefaultConfig(&c);
  c.fft_size = fft;
  c.band_count = bands;
  c.analysis_rate_hz = rate;
  return c;
}

// Slides the pipeline over a signal at the configured analysis rate.
void runPipeline(AnalysisPipeline& p, const Signal& s,
                 const std::function<void(const NoxiraAudioFrame&, size_t, double)>& onFrame) {
  const int n = p.windowSize();
  const int hop = s.sampleRate / p.config().analysis_rate_hz;
  const double dt = static_cast<double>(hop) / s.sampleRate;
  static NoxiraAudioFrame frame;
  for (size_t end = static_cast<size_t>(n); end <= s.size(); end += static_cast<size_t>(hop)) {
    p.process(s.left.data() + end - n, s.right.data() + end - n, dt, &frame);
    onFrame(frame, end, dt);
  }
}

int argmax(const float* v, int n) { return static_cast<int>(std::max_element(v, v + n) - v); }

int bandOf(const BandMapper& m, double hz) {
  int best = 0;
  double bestDist = 1e9;
  for (int i = 0; i < m.bandCount(); ++i) {
    const double d = std::fabs(std::log2(m.centerHz(i) / hz));
    if (d < bestDist) {
      bestDist = d;
      best = i;
    }
  }
  return best;
}

#define TEST(name) static void name()
struct Registered {
  const char* name;
  void (*fn)();
};
std::vector<Registered>& registry() {
  static std::vector<Registered> r;
  return r;
}
struct Registrar {
  Registrar(const char* name, void (*fn)()) { registry().push_back({name, fn}); }
};
#define REGISTER(name) static Registrar registrar_##name(#name, name)

// -------------------------------------------------------------------- FFT

TEST(fft_amplitude_and_bin_accuracy) {
  for (int size : {1024, 2048, 4096}) {
    for (int sr : {44100, 48000}) {
      RealFft fft;
      CHECK(fft.configure(size));
      const double binHz = static_cast<double>(sr) / size;
      for (int bin : {8, 37, size / 8, size / 4 + 3}) {
        const double hz = bin * binHz;  // exactly on a bin centre
        std::vector<float> x(size);
        for (int i = 0; i < size; ++i) {
          x[i] = static_cast<float>(0.5 * std::sin(kTwoPi * hz * i / sr));
        }
        std::vector<float> mag(fft.binCount());
        fft.amplitudeSpectrum(x.data(), mag.data());
        CHECK(argmax(mag.data(), fft.binCount()) == bin);
        CHECK_NEAR(mag[bin], 0.5, 0.01);
      }
    }
  }
  RealFft bad;
  CHECK(!bad.configure(1000));
}
REGISTER(fft_amplitude_and_bin_accuracy);

TEST(visualizer_pcm_capture_is_level_stable_and_silence_stays_silent) {
  RealFft fft;
  CHECK(fft.configure(4096));
  std::vector<float> left(4096), right(4096), amplitudeSpectrum(2049), spectrum(2048);
  float previous = 0;
  for (float amplitude : {0.8f, 0.4f, 0.1f, 0.02f}) {
    for (int i = 0; i < 4096; ++i) {
      left[i] = right[i] = amplitude * std::sin(kTwoPi * 64 * i / 4096);
    }
    fft.amplitudeSpectrum(left.data(), amplitudeSpectrum.data());
    visualizerSpectrum(amplitudeSpectrum.data(), left.data(), right.data(), 4096,
                        spectrum.data());
    CHECK(argmax(spectrum.data(), 2048) == 64);
    CHECK_NEAR(spectrum[64], 0.99f * 512.0f, 1.0f);
    if (previous != 0) CHECK_NEAR(spectrum[64], previous, 1.5);
    previous = spectrum[64];
  }
  std::fill(left.begin(), left.end(), 0.0f);
  std::fill(right.begin(), right.end(), 0.0f);
  fft.amplitudeSpectrum(left.data(), amplitudeSpectrum.data());
  visualizerSpectrum(amplitudeSpectrum.data(), left.data(), right.data(), 4096,
                      spectrum.data());
  for (float value : spectrum) CHECK(value == 0.0f);
}
REGISTER(visualizer_pcm_capture_is_level_stable_and_silence_stays_silent);

TEST(display_spectrum_tracks_low_and_mid_frequency_glides) {
  for (const auto& range : {std::make_pair(220.0, 60.0), std::make_pair(2400.0, 600.0)}) {
    AnalysisPipeline pipeline;
    NoxiraConfig cfg = makeConfig(4096);
    cfg.visualizer_spectrum = 1;
    CHECK(pipeline.configure(cfg, 48000));
    Signal signal = makeSignal(3.0);
    double phase = 0;
    for (size_t i = 0; i < signal.size(); ++i) {
      const double hz = range.first + (range.second - range.first) * i / signal.size();
      phase += kTwoPi * hz / signal.sampleRate;
      signal.left[i] = signal.right[i] = 0.5 * std::sin(phase) + 0.1 * std::sin(2 * phase);
    }
    int previousBin = INT32_MAX;
    runPipeline(pipeline, signal, [&](const NoxiraAudioFrame& frame, size_t end, double) {
      CHECK(frame.visualizer_spectrum_count == 2048);
      const int peak = argmax(frame.visualizer_spectrum, frame.visualizer_spectrum_count);
      const double windowCenter = end - cfg.fft_size / 2.0;
      const double expected = range.first +
          (range.second - range.first) * windowCenter / signal.size();
      CHECK_NEAR(peak * 48000.0 / cfg.fft_size, expected, 2 * 48000.0 / cfg.fft_size);
      CHECK(peak <= previousBin);
      previousBin = peak;
    });
  }
}
REGISTER(display_spectrum_tracks_low_and_mid_frequency_glides);

TEST(band_mapper_log_distribution) {
  for (int count : {32, 64, 128}) {
    BandMapper m;
    m.configure(count, 2048, 48000.0f, 20.0f, 20000.0f);
    CHECK(m.bandCount() == count);
    CHECK_NEAR(m.lowHz(0), 20.0, 0.01);
    CHECK_NEAR(m.highHz(count - 1), 20000.0, 20.0);
    const double ratio = m.centerHz(1) / m.centerHz(0);
    for (int i = 1; i < count; ++i) {
      CHECK(m.centerHz(i) > m.centerHz(i - 1));
      CHECK_NEAR(m.centerHz(i) / m.centerHz(i - 1), ratio, 1e-3);
      CHECK_NEAR(m.lowHz(i), m.highHz(i - 1), 1e-2);
    }
  }
  // maxHz above Nyquist is clamped, never read out of range.
  BandMapper low;
  low.configure(64, 1024, 22050.0f, 20.0f, 20000.0f);
  CHECK(low.highHz(63) <= 22050.0f * 0.5f);
  std::vector<float> mag(513, 0.1f), out(64);
  low.map(mag.data(), out.data());
  for (float v : out) CHECK(std::isfinite(v));
}
REGISTER(band_mapper_log_distribution);

TEST(config_sanitize) {
  NoxiraConfig c;
  fillDefaultConfig(&c);
  c.fft_size = 3000;
  c.band_count = 100;
  c.analysis_rate_hz = 1000;
  c.spectrum_bins = 7;
  c.noise_floor_db = 5.0f;
  c.region_edges_hz[3] = 1.0f;  // not ascending -> defaults
  sanitizeConfig(&c);
  CHECK(c.fft_size == 2048 || c.fft_size == 4096);
  CHECK(c.band_count == 128);
  CHECK(c.analysis_rate_hz == 120);
  CHECK(c.spectrum_bins >= 32);
  CHECK(c.noise_floor_db <= -20.0f);
  CHECK(c.region_edges_hz[3] == 500.0f);
  c.contrast = 100.0f;
  c.global_reference_mix = -3.0f;
  sanitizeConfig(&c);
  CHECK(c.contrast == 4.0f);
  CHECK(c.global_reference_mix == 0.0f);
  c.level_floor = 5.0f;
  sanitizeConfig(&c);
  CHECK(c.level_floor == 0.9f);
  c.normalization_attack_ms = -5.0f;
  sanitizeConfig(&c);
  CHECK(c.normalization_attack_ms == 0.0f);
}
REGISTER(config_sanitize);

// ------------------------------------------------------------ signal analysis

TEST(silence_is_silent) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(), 48000.0f));
  Signal s = makeSignal(1.0);
  float maxBand = 0, maxRegion = 0, energy = 0;
  int silentFlags = 0, frames = 0;
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) {
    ++frames;
    for (int i = 0; i < f.band_count; ++i) maxBand = std::max(maxBand, f.bands[i]);
    for (int i = 0; i < NOXIRA_REGION_COUNT; ++i) maxRegion = std::max(maxRegion, f.regions[i]);
    energy = std::max(energy, f.energy);
    if (f.flags & NOXIRA_FLAG_SILENT) ++silentFlags;
  });
  CHECK(frames > 30);
  CHECK(maxBand == 0.0f);
  CHECK(maxRegion == 0.0f);
  CHECK(energy == 0.0f);
  CHECK(silentFlags == frames);
  CHECK(p.idle());
}
REGISTER(silence_is_silent);

TEST(noise_below_floor_stays_zero) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(), 48000.0f));
  Signal s = makeSignal(1.0);
  std::mt19937 rng(1);
  std::uniform_real_distribution<float> d(-1e-5f, 1e-5f);  // about -100 dBFS
  for (size_t i = 0; i < s.size(); ++i) s.left[i] = s.right[i] = d(rng);
  float maxBand = 0;
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) {
    for (int i = 0; i < f.band_count; ++i) maxBand = std::max(maxBand, f.bands[i]);
  });
  CHECK(maxBand == 0.0f);
}
REGISTER(noise_below_floor_stays_zero);

TEST(sine_1khz_measurements) {
  for (int fft : {1024, 2048, 4096}) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig(fft, 64, 60);
    CHECK(p.configure(cfg, 48000.0f));
    BandMapper map;
    map.configure(64, fft, 48000.0f, 20.0f, 20000.0f);
    Signal s = makeSignal(2.0);
    addSine(s, 1000.0, 0.5);
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });

    const int expected = bandOf(map, 1000.0);
    const int got = argmax(last.bands, 64);
    CHECK(std::abs(got - expected) <= 1);
    CHECK(last.bands[got] > 0.85f);
    // Bands an octave or more away are clearly lower.
    CHECK(last.bands[bandOf(map, 250.0)] < 0.5f * last.bands[got]);
    CHECK(last.bands[bandOf(map, 6000.0)] < 0.5f * last.bands[got]);
    CHECK_NEAR(last.rms, 0.5 / std::sqrt(2.0), 0.02);
    CHECK_NEAR(last.peak, 0.5, 0.01);
    CHECK_NEAR(last.centroid_hz, 1000.0, 90.0);
    CHECK_NEAR(last.zero_crossing_rate, 2.0 * 1000.0 / 48000.0, 0.004);
    CHECK(argmax(last.regions, NOXIRA_REGION_COUNT) == 3);  // midrange 500-2000
    CHECK(last.stereo_correlation > 0.99f);
    CHECK(last.stereo_width < 0.02f);
    CHECK_NEAR(last.stereo_balance, 0.0, 0.02);
    CHECK(last.sample_rate == 48000);
    CHECK(last.fft_size == fft);
    CHECK(last.band_count == 64);
    CHECK(last.energy > 0.3f);
    // The exported spectrum peaks at the right place.
    const double binHz = 48000.0 / fft;
    const int spectrumGroup = (fft / 2) / last.spectrum_count;
    const int peakEntry = argmax(last.spectrum, last.spectrum_count);
    CHECK_NEAR((peakEntry + 0.5) * spectrumGroup * binHz, 1000.0, 2.0 * spectrumGroup * binHz);
  }
}
REGISTER(sine_1khz_measurements);

TEST(mixed_frequencies_regions) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(4096, 64, 60), 48000.0f));
  Signal s = makeSignal(2.0);
  addSine(s, 100.0, 0.25);
  addSine(s, 1000.0, 0.25);
  addSine(s, 8000.0, 0.25);
  NoxiraAudioFrame last{};
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
  BandMapper map;
  map.configure(64, 4096, 48000.0f, 20.0f, 20000.0f);
  // three distinct peaks at the right bands
  for (double hz : {100.0, 1000.0, 8000.0}) {
    const int b = bandOf(map, hz);
    CHECK(last.bands[b] > 0.6f);
  }
  CHECK(last.regions[1] > 0.4f);  // bass 60-250
  CHECK(last.regions[3] > 0.4f);  // mid 500-2000
  CHECK(last.regions[6] > 0.4f);  // high 8000-20000 (8 kHz sits on the edge)
  CHECK(last.regions[0] < 0.5f * last.regions[1]);  // sub-bass: only window leakage
  CHECK(last.regions[2] < 0.1f);  // low mids empty
  CHECK(last.regions[4] < 0.1f);  // upper mids empty
}
REGISTER(mixed_frequencies_regions);

TEST(sub_bass_region) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(4096, 64, 60), 48000.0f));
  Signal s = makeSignal(2.0);
  addSine(s, 45.0, 0.5);
  NoxiraAudioFrame last{};
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
  CHECK(argmax(last.regions, NOXIRA_REGION_COUNT) == 0);
  CHECK(last.regions[0] > 0.8f);
  CHECK(last.bass_activity > 0.8f);
  CHECK(last.regions[3] < 0.05f);
}
REGISTER(sub_bass_region);

TEST(stereo_analysis) {
  struct Case {
    bool l, r;
    double phaseR;
    double corr, width, balance;
  };
  AnalysisPipeline p;
  NoxiraConfig cfg = makeConfig();
  cfg.stereo_bands = 1;
  CHECK(p.configure(cfg, 48000.0f));

  auto measure = [&](Signal& s) {
    p.reset();
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
    return last;
  };

  Signal leftOnly = makeSignal(1.0);
  addSine(leftOnly, 1000.0, 0.5, 0.0, true, false);
  NoxiraAudioFrame f = measure(leftOnly);
  CHECK_NEAR(f.stereo_balance, -1.0, 0.02);
  CHECK(std::fabs(f.stereo_correlation) < 0.05f);
  CHECK(f.rms_left > 0.3f && f.rms_right < 1e-6f);
  const int b = argmax(f.bands_left, 64);
  CHECK(f.bands_left[b] > 0.8f);
  CHECK(f.bands_right[b] < 0.05f);

  Signal rightOnly = makeSignal(1.0);
  addSine(rightOnly, 1000.0, 0.5, 0.0, false, true);
  f = measure(rightOnly);
  CHECK_NEAR(f.stereo_balance, 1.0, 0.02);

  Signal mono = makeSignal(1.0);
  addSine(mono, 1000.0, 0.5);
  f = measure(mono);
  CHECK(f.stereo_correlation > 0.99f);
  CHECK(f.stereo_width < 0.02f);

  Signal outOfPhase = makeSignal(1.0);
  addSine(outOfPhase, 1000.0, 0.5, 0.0, true, false);
  addSine(outOfPhase, 1000.0, 0.5, kTwoPi / 2, false, true);
  f = measure(outOfPhase);
  CHECK(f.stereo_correlation < -0.99f);
  CHECK(f.stereo_width > 0.95f);

  Signal wide = makeSignal(1.0);
  addSine(wide, 440.0, 0.4, 0.0, true, false);
  addSine(wide, 660.0, 0.4, 0.0, false, true);
  f = measure(wide);
  CHECK(std::fabs(f.stereo_correlation) < 0.2f);
  CHECK(f.stereo_width > 0.3f);
}
REGISTER(stereo_analysis);

TEST(normalization_quiet_and_loud) {
  auto settle = [&](double amp) {
    AnalysisPipeline p;
    CHECK(p.configure(makeConfig(), 48000.0f));
    Signal s = makeSignal(3.0);
    addSine(s, 1000.0, amp);
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
    return last;
  };
  const NoxiraAudioFrame loud = settle(0.5);                       // -6 dBFS
  const NoxiraAudioFrame quiet = settle(0.5 * std::pow(10.0, -34.0 / 20.0));  // -40 dBFS
  const NoxiraAudioFrame faint = settle(0.5 * std::pow(10.0, -94.0 / 20.0));  // -100 dBFS
  float maxLoud = *std::max_element(loud.bands, loud.bands + 64);
  float maxQuiet = *std::max_element(quiet.bands, quiet.bands + 64);
  float maxFaint = *std::max_element(faint.bands, faint.bands + 64);
  CHECK(maxLoud > 0.85f);
  CHECK(maxQuiet > 0.1f);        // still visible, not gated away
  CHECK(maxQuiet < maxLoud);     // but not stretched to full scale
  CHECK(maxFaint == 0.0f);       // below the noise floor: silence stays silent
  CHECK(faint.flags & NOXIRA_FLAG_SILENT);
}
REGISTER(normalization_quiet_and_loud);

TEST(default_normalization_preserves_level_differences_and_headroom) {
  NoxiraConfig cfg = makeConfig();
  CHECK(cfg.global_reference_mix == 1.0f);
  CHECK(cfg.sensitivity_tilt_db_per_octave == 0.0f);
  CHECK(cfg.level_floor == 0.0f);
  CHECK(cfg.contrast == 1.0f);
  CHECK(cfg.normalization_attack_ms == 0.0f);
  DynamicNormalizer normalizer;
  normalizer.configure(4, cfg.dynamic_range_db, cfg.min_reference_db,
                      cfg.normalization_release_db_per_sec, cfg.global_reference_mix);
  const float levels[] = {-12.0f, -24.0f, -48.0f, kSilenceDb};
  float values[4]{};
  for (int frame = 0; frame < 60 * 30; ++frame) {
    normalizer.process(levels, values, 1.0f / 60.0f);
    CHECK_NEAR(values[0], 0.875, 1e-5);
    CHECK_NEAR(values[1], 0.625, 1e-5);
    CHECK_NEAR(values[2], 0.125, 1e-5);
    CHECK(values[3] == 0.0f);
  }
  // Silence cannot lower the reference beyond the configured gain limit.
  const float silence[] = {kSilenceDb, kSilenceDb, kSilenceDb, kSilenceDb};
  normalizer.process(silence, values, 120.0f);
  CHECK_NEAR(normalizer.globalReferenceDb(), cfg.min_reference_db, 1e-5);
  for (float v : values) CHECK(v == 0.0f);
}
REGISTER(default_normalization_preserves_level_differences_and_headroom);

TEST(default_bands_do_not_clip_or_inflate_quiet_frequencies) {
  AnalysisPipeline pipeline;
  const NoxiraConfig cfg = makeConfig();
  CHECK(pipeline.configure(cfg, 48000.0f));
  Signal s = makeSignal(5.0);
  addSine(s, 187.5, 0.5);
  addSine(s, 3000.0, 0.03125);  // 24 dB below the bass, not another full-height band
  BandMapper map;
  map.configure(64, cfg.fft_size, 48000.0f, cfg.min_hz, cfg.max_hz);
  const int bass = bandOf(map, 187.5);
  const int mid = bandOf(map, 3000.0);
  const int quiet = bandOf(map, 12000.0);
  runPipeline(pipeline, s, [&](const NoxiraAudioFrame& f, size_t end, double) {
    for (int i = 0; i < f.band_count; ++i) CHECK(f.bands[i] <= 0.876f);
    if (end > 48000 * 2) {
      CHECK(f.bands[bass] > 0.75f);
      CHECK(f.bands[mid] > 0.25f);
      CHECK(f.bands[mid] < f.bands[bass] - 0.35f);
      CHECK(f.bands[quiet] == 0.0f);
    }
  });
}
REGISTER(default_bands_do_not_clip_or_inflate_quiet_frequencies);

TEST(contrast_and_reference_mix_shape_levels) {
  // A loud tone plus a much quieter one: raising the contrast and the global
  // reference mix lowers the quiet tone relative to the loud one.
  Signal s = makeSignal(3.0);
  addSine(s, 200.0, 0.5);
  addSine(s, 3000.0, 0.5 * std::pow(10.0, -24.0 / 20.0));
  BandMapper map;
  map.configure(64, 2048, 48000.0f, 20.0f, 20000.0f);
  auto quietLevel = [&](float contrast, float mix) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig();
    cfg.contrast = contrast;
    cfg.global_reference_mix = mix;
    CHECK(p.configure(cfg, 48000.0f));
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
    // The strongest band retains 6 dB of headroom before the power curve.
    CHECK_NEAR(last.bands[argmax(last.bands, 64)], std::pow(0.875, contrast), 0.02);
    return last.bands[bandOf(map, 3000.0)];
  };
  const float flat = quietLevel(1.0f, 0.5f);
  const float shaped = quietLevel(2.0f, 0.9f);
  CHECK(flat > 0.4f);
  CHECK(shaped < 0.7f * flat);
  CHECK(shaped >= 0.0f);

  // The floor is applied before contrast, including the normalization headroom.
  AnalysisPipeline gated;
  NoxiraConfig cfg = makeConfig();
  cfg.level_floor = 0.8f;
  CHECK(gated.configure(cfg, 48000.0f));
  NoxiraAudioFrame last{};
  runPipeline(gated, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
  CHECK_NEAR(last.bands[argmax(last.bands, 64)], (0.875 - 0.8) / 0.2, 0.02);
  CHECK(last.bands[bandOf(map, 3000.0)] < 0.7f * flat);
}
REGISTER(contrast_and_reference_mix_shape_levels);

TEST(normalization_attack_lets_peaks_overshoot) {
  // A short loud burst must not pull the level of a steady quieter tone down
  // for seconds when the reference rises slowly.
  Signal s = makeSignal(4.0);
  addSine(s, 3000.0, 0.5 * std::pow(10.0, -24.0 / 20.0));
  addSine(s, 200.0, 0.8, 0.0, true, true, 48000 * 2, 48000 * 2 + 4800);  // 100 ms burst
  BandMapper map;
  map.configure(64, 2048, 48000.0f, 20.0f, 20000.0f);
  const int band = bandOf(map, 3000.0);
  auto levelAfterBurst = [&](float attackMs) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig();
    cfg.global_reference_mix = 0.9f;
    cfg.normalization_attack_ms = attackMs;
    CHECK(p.configure(cfg, 48000.0f));
    float level = 0.0f;
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t end, double) {
      if (end > 48000 * 3 - 1000 && end < 48000 * 3) level = f.bands[band];  // 1 s later
    });
    return level;
  };
  const float instant = levelAfterBurst(0.0f);
  const float slow = levelAfterBurst(800.0f);
  CHECK(slow > instant + 0.1f);
}
REGISTER(normalization_attack_lets_peaks_overshoot);

TEST(smoothing_is_time_based) {
  // The time a band takes to fall to 1/e after the sound stops must not
  // depend on the analysis rate.
  auto fallTime = [&](int rate) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig(2048, 64, rate);
    cfg.release_ms = 200.0f;
    CHECK(p.configure(cfg, 48000.0f));
    Signal s = makeSignal(3.0);
    addSine(s, 1000.0, 0.5, 0.0, true, true, 0, 48000 * 2);
    double peak = 0, t = 0, tFall = -1;
    int band = -1;
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t end, double dt) {
      if (end < 48000 * 2) {
        band = argmax(f.bands, 64);
        peak = f.bands[band];
        return;
      }
      // silent frames: the pipeline sees silence only after the window clears,
      // so measure from the first frame where the whole window is silent.
      if (end - p.windowSize() < 48000 * 2) return;
      t += dt;
      if (tFall < 0 && f.bands[band] < peak / std::exp(1.0)) tFall = t;
    });
    return tFall;
  };
  const double t30 = fallTime(30), t60 = fallTime(60), t120 = fallTime(120);
  CHECK(t30 > 0 && t60 > 0 && t120 > 0);
  CHECK_NEAR(t30, t60, 0.04);
  CHECK_NEAR(t60, t120, 0.04);
  CHECK_NEAR(t60, 0.2, 0.06);
}
REGISTER(smoothing_is_time_based);

TEST(band_decay_matches_release_without_normalization_pumping) {
  AnalysisPipeline pipeline;
  const NoxiraConfig cfg = makeConfig();
  CHECK(pipeline.configure(cfg, 48000.0f));
  Signal s = makeSignal(1.0);
  addSine(s, 1000.0, 0.5);
  NoxiraAudioFrame last{};
  runPipeline(pipeline, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
  const int band = argmax(last.bands, 64);
  const float initial = last.bands[band];
  for (int i = 1; i <= 30; ++i) {
    pipeline.decay(1.0 / 60.0, &last);
    const double expected = initial * std::exp(-(i / 60.0) / (cfg.release_ms / 1000.0));
    CHECK_NEAR(last.bands[band], expected, 1e-5);
  }
}
REGISTER(band_decay_matches_release_without_normalization_pumping);
TEST(peak_hold_and_decay) {
  AnalysisPipeline p;
  NoxiraConfig cfg = makeConfig(2048, 64, 60);
  cfg.peak_hold_ms = 400.0f;
  cfg.peak_decay_per_sec = 1.0f;
  cfg.release_ms = 50.0f;
  CHECK(p.configure(cfg, 48000.0f));
  Signal s = makeSignal(3.0);
  addSine(s, 1000.0, 0.5, 0.0, true, true, 0, 48000);
  int band = -1;
  float peakAtEnd = 0, heldAt200 = 0, decayedAt1500 = 0;
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t end, double) {
    if (end <= 48000) {
      band = argmax(f.bands, 64);
      peakAtEnd = f.band_peaks[band];
      return;
    }
    const double since = (static_cast<double>(end) - 48000.0 - p.windowSize()) / 48000.0;
    if (since > 0.15 && since < 0.2) heldAt200 = f.band_peaks[band];
    if (since > 1.45 && since < 1.5) decayedAt1500 = f.band_peaks[band];
  });
  CHECK(peakAtEnd > 0.8f);
  CHECK(heldAt200 >= peakAtEnd - 0.05f);  // still holding
  CHECK(decayedAt1500 < peakAtEnd - 0.3f);  // has fallen
}
REGISTER(peak_hold_and_decay);

// ------------------------------------------------------- transients / music

// Envelope-shaped burst helpers.
void addKick(Signal& s, double t) {
  const size_t start = static_cast<size_t>(t * s.sampleRate);
  for (size_t i = 0; i < static_cast<size_t>(0.12 * s.sampleRate) && start + i < s.size(); ++i) {
    const double tt = static_cast<double>(i) / s.sampleRate;
    const double f = 55.0 + 60.0 * std::exp(-tt * 40.0);  // pitch drop
    const double v = 0.8 * std::exp(-tt * 28.0) * std::sin(kTwoPi * f * tt);
    s.left[start + i] += static_cast<float>(v);
    s.right[start + i] += static_cast<float>(v);
  }
}
void addNoiseBurst(Signal& s, double t, double decay, double amp, double lowHz, double highHz,
                   std::mt19937& rng) {
  // Band-limited noise by summing random-phase sines (deterministic).
  const size_t start = static_cast<size_t>(t * s.sampleRate);
  const size_t len = static_cast<size_t>(0.2 * s.sampleRate);
  std::uniform_real_distribution<double> ph(0, kTwoPi);
  const int partials = 60;
  std::vector<double> freqs(partials), phases(partials);
  for (int k = 0; k < partials; ++k) {
    freqs[k] = lowHz + (highHz - lowHz) * (k + 0.5) / partials;
    phases[k] = ph(rng);
  }
  for (size_t i = 0; i < len && start + i < s.size(); ++i) {
    const double tt = static_cast<double>(i) / s.sampleRate;
    double v = 0;
    for (int k = 0; k < partials; ++k) v += std::sin(kTwoPi * freqs[k] * tt + phases[k]);
    v *= amp * std::exp(-tt * decay) * std::min(1.0, tt / 0.002) / std::sqrt(partials / 2.0);
    s.left[start + i] += static_cast<float>(v);
    s.right[start + i] += static_cast<float>(v);
  }
}

struct EventCounts {
  int onset = 0, beat = 0, kick = 0, snare = 0, hihat = 0;
  float bpm = 0, beatConfidence = 0, maxTransientAtHit = 0;
};

EventCounts runEvents(const Signal& s, int fft = 2048, double skipSeconds = 0.0) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(fft, 64, 60), static_cast<float>(s.sampleRate)));
  EventCounts c;
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t end, double) {
    if (static_cast<double>(end) / s.sampleRate < skipSeconds) return;
    if (f.flags & NOXIRA_FLAG_ONSET) ++c.onset;
    if (f.flags & NOXIRA_FLAG_BEAT) ++c.beat;
    if (f.flags & NOXIRA_FLAG_KICK) ++c.kick;
    if (f.flags & NOXIRA_FLAG_SNARE) ++c.snare;
    if (f.flags & NOXIRA_FLAG_HIHAT) ++c.hihat;
    c.bpm = f.bpm;
    c.beatConfidence = f.beat_confidence;
    c.maxTransientAtHit = std::max(c.maxTransientAtHit, f.transient);
  });
  return c;
}

TEST(kick_pattern_detected) {
  std::mt19937 rng(7);
  Signal s = makeSignal(10.0);
  int hits = 0;
  for (double t = 0.5; t < 9.5; t += 0.5) {  // 120 BPM
    addKick(s, t);
    ++hits;
  }
  const EventCounts c = runEvents(s);
  CHECK(c.kick >= hits * 8 / 10);
  CHECK(c.kick <= hits * 14 / 10);
  CHECK(c.hihat <= hits / 4);
  CHECK(c.onset >= hits * 8 / 10);
  CHECK(c.beat >= hits * 7 / 10);
  CHECK_NEAR(c.bpm, 120.0, 8.0);
  CHECK(c.beatConfidence > 0.5f);
  CHECK(c.maxTransientAtHit > 0.5f);
  (void)rng;
}
REGISTER(kick_pattern_detected);

TEST(hihat_pattern_detected) {
  std::mt19937 rng(11);
  Signal s = makeSignal(8.0);
  int hits = 0;
  for (double t = 0.5; t < 7.5; t += 0.25) {
    addNoiseBurst(s, t, 60.0, 0.5, 7000.0, 15000.0, rng);
    ++hits;
  }
  const EventCounts c = runEvents(s);
  CHECK(c.hihat >= hits * 7 / 10);
  CHECK(c.kick <= hits / 5);
  CHECK(c.snare <= hits / 3);
}
REGISTER(hihat_pattern_detected);

TEST(snare_pattern_detected) {
  std::mt19937 rng(5);
  Signal s = makeSignal(8.0);
  int hits = 0;
  for (double t = 0.5; t < 7.5; t += 0.5) {
    addNoiseBurst(s, t, 25.0, 0.6, 180.0, 7000.0, rng);  // broadband
    ++hits;
  }
  const EventCounts c = runEvents(s);
  CHECK(c.snare >= hits * 7 / 10);
  CHECK(c.kick <= hits / 2);
}
REGISTER(snare_pattern_detected);

TEST(steady_tone_produces_no_events) {
  Signal s = makeSignal(6.0);
  addSine(s, 440.0, 0.4);
  const EventCounts c = runEvents(s, 2048, 1.0);
  CHECK(c.onset <= 1);
  CHECK(c.kick == 0);
  CHECK(c.snare == 0);
  CHECK(c.hihat == 0);
  CHECK(c.beat == 0);
}
REGISTER(steady_tone_produces_no_events);

TEST(impulses_are_onsets) {
  std::mt19937 rng(21);
  Signal s = makeSignal(6.0);
  int clicks = 0;
  for (double t = 0.5; t < 5.5; t += 0.4) {
    const size_t i = static_cast<size_t>(t * s.sampleRate);
    // A short burst of decaying noise: a broadband click.
    for (int k = 0; k < 96; ++k) {
      const float v = 0.9f * std::exp(-k / 20.0f) * ((rng() % 2001) / 1000.0f - 1.0f);
      s.left[i + k] = s.right[i + k] = v;
    }
    ++clicks;
  }
  const EventCounts c = runEvents(s);
  CHECK(c.onset >= clicks * 8 / 10);
  CHECK(c.onset <= clicks * 15 / 10);
}
REGISTER(impulses_are_onsets);

TEST(seek_does_not_create_onsets) {
  AnalysisPipeline p;
  CHECK(p.configure(makeConfig(), 48000.0f));
  Signal a = makeSignal(2.0), b = makeSignal(2.0);
  addSine(a, 220.0, 0.3);
  addSine(b, 3000.0, 0.5);
  int onsets = 0;
  runPipeline(p, a, [&](const NoxiraAudioFrame&, size_t, double) {});
  p.softReset();  // seek to a very different part of the song
  runPipeline(p, b, [&](const NoxiraAudioFrame& f, size_t end, double) {
    if (end < 48000 * 0.2 && (f.flags & NOXIRA_FLAG_ONSET)) ++onsets;
  });
  CHECK(onsets == 0);
}
REGISTER(seek_does_not_create_onsets);

TEST(sample_rate_independence) {
  for (int sr : {22050, 32000, 44100, 48000, 96000}) {
    AnalysisPipeline p;
    CHECK(p.configure(makeConfig(2048, 64, 60), static_cast<float>(sr)));
    Signal s = makeSignal(1.5, sr);
    addSine(s, 2000.0, 0.5);
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
    BandMapper map;
    map.configure(64, 2048, static_cast<float>(sr), 20.0f, 20000.0f);
    CHECK(std::abs(argmax(last.bands, 64) - bandOf(map, 2000.0)) <= 1);
    CHECK_NEAR(last.centroid_hz, 2000.0, 200.0);
    CHECK(last.sample_rate == sr);
  }
}
REGISTER(sample_rate_independence);

TEST(output_is_finite_and_bounded) {
  AnalysisPipeline p;
  NoxiraConfig cfg = makeConfig(4096, 128, 120);
  cfg.stereo_bands = 1;
  CHECK(p.configure(cfg, 44100.0f));
  Signal s = makeSignal(3.0, 44100);
  std::mt19937 rng(3);
  std::uniform_real_distribution<float> d(-1.5f, 1.5f);  // hot, clipped-looking input
  for (size_t i = 0; i < s.size(); ++i) {
    s.left[i] = d(rng);
    s.right[i] = d(rng);
  }
  bool ok = true;
  runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) {
    auto bounded = [&](const float* v, int n) {
      for (int i = 0; i < n; ++i) {
        if (!std::isfinite(v[i]) || v[i] < 0.0f || v[i] > 1.0f) ok = false;
      }
    };
    bounded(f.bands, f.band_count);
    bounded(f.bands_left, f.band_count);
    bounded(f.bands_right, f.band_count);
    bounded(f.band_peaks, f.band_count);
    bounded(f.spectrum, f.spectrum_count);
    bounded(f.regions, NOXIRA_REGION_COUNT);
    for (float v : {f.energy, f.flux, f.transient, f.kick, f.snare, f.hihat, f.percussion,
                    f.bass_activity, f.centroid, f.beat_confidence}) {
      if (!std::isfinite(v) || v < 0.0f || v > 1.0f) ok = false;
    }
    if (!std::isfinite(f.rms) || !std::isfinite(f.centroid_hz) || !std::isfinite(f.bpm)) ok = false;
    if (f.stereo_correlation < -1.0f || f.stereo_correlation > 1.0f) ok = false;
    if (f.stereo_balance < -1.0f || f.stereo_balance > 1.0f) ok = false;
  });
  CHECK(ok);
}
REGISTER(output_is_finite_and_bounded);

TEST(frequency_dependent_sensitivity) {
  Signal s = makeSignal(2.0);
  addSine(s, 100.0, 0.1);
  addSine(s, 5000.0, 0.1);
  BandMapper map;
  map.configure(64, 2048, 48000.0f, 20.0f, 20000.0f);
  auto measure = [&](float tilt, float boostHighBands) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig();
    cfg.sensitivity_tilt_db_per_octave = tilt;
    for (int i = 40; i < 64; ++i) cfg.band_sensitivity_db[i] = boostHighBands;
    CHECK(p.configure(cfg, 48000.0f));
    NoxiraAudioFrame last{};
    runPipeline(p, s, [&](const NoxiraAudioFrame& f, size_t, double) { last = f; });
    return std::make_pair(last.bands[bandOf(map, 100.0)], last.bands[bandOf(map, 5000.0)]);
  };
  const auto flat = measure(0.0f, 0.0f);
  const auto tilted = measure(6.0f, 0.0f);
  // A positive tilt raises the high band relative to the low band.
  CHECK(tilted.second / std::max(tilted.first, 1e-3f) > flat.second / std::max(flat.first, 1e-3f));
}
REGISTER(frequency_dependent_sensitivity);

// ------------------------------------------------------------ PCM + buffers

TEST(pcm_conversion) {
  StereoRing ring(1024);
  std::vector<float> l(8), r(8);

  const int16_t s16[] = {16384, -16384, 32767, -32768};  // 2 stereo frames
  pushPcm(ring, s16, 2, 2, NOXIRA_PCM_S16);
  CHECK(ring.read(0, 2, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.5, 1e-4);
  CHECK_NEAR(r[0], -0.5, 1e-4);
  CHECK_NEAR(l[1], 32767.0 / 32768.0, 1e-4);
  CHECK_NEAR(r[1], -1.0, 1e-4);

  const float mono[] = {0.25f, -0.5f};
  pushPcm(ring, mono, 2, 1, NOXIRA_PCM_F32);
  CHECK(ring.read(2, 2, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.25, 1e-6);
  CHECK_NEAR(r[0], 0.25, 1e-6);
  CHECK_NEAR(r[1], -0.5, 1e-6);

  const uint8_t s24[] = {0x00, 0x00, 0x40, 0x00, 0x00, 0xC0};  // +0.5, -0.5
  pushPcm(ring, s24, 1, 2, NOXIRA_PCM_S24);
  CHECK(ring.read(4, 1, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.5, 1e-6);
  CHECK_NEAR(r[0], -0.5, 1e-6);

  const int32_t s32[] = {1 << 30, -(1 << 30)};
  pushPcm(ring, s32, 1, 2, NOXIRA_PCM_S32);
  CHECK(ring.read(5, 1, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.5, 1e-6);
  CHECK_NEAR(r[0], -0.5, 1e-6);

  const uint8_t u8[] = {192, 64};  // +0.5, -0.5
  pushPcm(ring, u8, 1, 2, NOXIRA_PCM_U8);
  CHECK(ring.read(6, 1, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.5, 1e-6);
  CHECK_NEAR(r[0], -0.5, 1e-6);

  // 5.1 (FL FR FC LFE BL BR): LFE must not contribute, centre goes to both.
  StereoRing ring6(1024);
  const float surround[] = {0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};  // LFE only
  pushPcm(ring6, surround, 1, 6, NOXIRA_PCM_F32);
  CHECK(ring6.read(0, 1, 0, l.data(), r.data()));
  CHECK_NEAR(l[0], 0.0, 1e-6);
  CHECK_NEAR(r[0], 0.0, 1e-6);
  const float centre[] = {0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f};
  pushPcm(ring6, centre, 1, 6, NOXIRA_PCM_F32);
  CHECK(ring6.read(1, 1, 0, l.data(), r.data()));
  CHECK(l[0] > 0.1f && std::fabs(l[0] - r[0]) < 1e-6f);
  const float leftFront[] = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
  pushPcm(ring6, leftFront, 1, 6, NOXIRA_PCM_F32);
  CHECK(ring6.read(2, 1, 0, l.data(), r.data()));
  CHECK(l[0] > 0.1f && r[0] == 0.0f);
  // Full-scale in every channel must not clip after the fold-down.
  const float full[12] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
  StereoRing ring12(1024);
  pushPcm(ring12, full, 1, 12, NOXIRA_PCM_F32);
  CHECK(ring12.read(0, 1, 0, l.data(), r.data()));
  CHECK(l[0] <= 2.6f && r[0] <= 2.6f);

  // Unknown encodings / bad arguments push nothing.
  const uint64_t before = ring.head();
  pushPcm(ring, s16, 2, 2, 99);
  pushPcm(ring, nullptr, 2, 2, NOXIRA_PCM_S16);
  pushPcm(ring, s16, 0, 2, NOXIRA_PCM_S16);
  CHECK(ring.head() == before);
}
REGISTER(pcm_conversion);

TEST(ring_wrap_and_overrun) {
  StereoRing ring(256);
  std::vector<float> l(300), r(300), out_l(100), out_r(100);
  for (int block = 0; block < 10; ++block) {
    for (int i = 0; i < 100; ++i) l[i] = r[i] = static_cast<float>(block * 100 + i);
    ring.push(l.data(), r.data(), 100);
  }
  CHECK(ring.head() == 1000);
  // the newest 100 frames are readable and correct
  CHECK(ring.read(900, 100, 0, out_l.data(), out_r.data()));
  for (int i = 0; i < 100; ++i) CHECK(out_l[i] == static_cast<float>(900 + i));
  // frames older than the capacity are reported as lost, not returned torn
  CHECK(!ring.read(100, 100, 0, out_l.data(), out_r.data()));
  // reading the future fails
  CHECK(!ring.read(950, 100, 0, out_l.data(), out_r.data()));
  // frames before the stream start are zero filled
  CHECK(ring.read(900, 100, 950, out_l.data(), out_r.data()));
  CHECK(out_l[0] == 0.0f && out_l[49] == 0.0f && out_l[50] == 950.0f);
}
REGISTER(ring_wrap_and_overrun);

TEST(ring_producer_consumer_stress) {
  StereoRing ring(1 << 14);
  std::atomic<bool> stop{false};
  std::thread producer([&] {
    std::vector<float> block(256);
    uint64_t counter = 0;
    while (!stop.load()) {
      for (auto& v : block) v = static_cast<float>(counter++ % 100000);
      ring.push(block.data(), block.data(), 256);
      std::this_thread::sleep_for(std::chrono::microseconds(200));
    }
  });
  int valid = 0, torn = 0;
  std::vector<float> l(512), r(512);
  const auto until = std::chrono::steady_clock::now() + std::chrono::milliseconds(400);
  while (std::chrono::steady_clock::now() < until) {
    const uint64_t head = ring.head();
    if (head < 1024) continue;
    if (ring.read(head - 512, 512, 0, l.data(), r.data())) {
      ++valid;
      // values are a running counter modulo 100000: consecutive samples differ by 1
      for (int i = 1; i < 512; ++i) {
        const float d = l[i] - l[i - 1];
        if (d != 1.0f && d != -99999.0f) {
          ++torn;
          break;
        }
      }
    }
  }
  stop = true;
  producer.join();
  CHECK(valid > 10);
  CHECK(torn == 0);
}
REGISTER(ring_producer_consumer_stress);

TEST(triple_buffer_no_tearing) {
  struct Payload {
    uint64_t a[64];
  };
  TripleBuffer<Payload> tb;
  std::atomic<bool> stop{false};
  std::thread writer([&] {
    uint64_t n = 0;
    while (!stop.load()) {
      Payload* p = tb.back();
      for (auto& v : p->a) v = n;
      tb.publish();
      ++n;
      if (n % 64 == 0) std::this_thread::yield();
    }
  });
  int reads = 0, torn = 0;
  uint64_t lastValue = 0;
  bool monotonic = true;
  const auto until = std::chrono::steady_clock::now() + std::chrono::milliseconds(300);
  while (std::chrono::steady_clock::now() < until) {
    const Payload* p = tb.acquire();
    if (!p) continue;
    ++reads;
    for (int i = 1; i < 64; ++i) {
      if (p->a[i] != p->a[0]) {
        ++torn;
        break;
      }
    }
    if (p->a[0] < lastValue) monotonic = false;
    lastValue = p->a[0];
  }
  stop = true;
  writer.join();
  CHECK(reads > 100);
  CHECK(torn == 0);
  CHECK(monotonic);
}
REGISTER(triple_buffer_no_tearing);

// ------------------------------------------------------- engine integration

// Feeds a sine into a source at real-time pace on this thread.
void feedRealtime(int source, double hz, double amp, int sampleRate, int channels,
                  double seconds, int chunkMs = 10) {
  const int chunk = sampleRate * chunkMs / 1000;
  std::vector<int16_t> pcm(static_cast<size_t>(chunk) * channels);
  uint64_t n = 0;
  const auto t0 = std::chrono::steady_clock::now();
  const int chunks = static_cast<int>(seconds * 1000 / chunkMs);
  for (int c = 0; c < chunks; ++c) {
    for (int i = 0; i < chunk; ++i, ++n) {
      const int16_t v = static_cast<int16_t>(
          32767.0 * amp * std::sin(kTwoPi * hz * static_cast<double>(n) / sampleRate));
      for (int ch = 0; ch < channels; ++ch) pcm[static_cast<size_t>(i) * channels + ch] = v;
    }
    noxira_engine_push_pcm(source, pcm.data(), chunk, NOXIRA_PCM_S16);
    std::this_thread::sleep_until(t0 + std::chrono::milliseconds((c + 1) * chunkMs));
  }
}

NoxiraAudioFrame latestFrame() {
  NoxiraAudioFrame out{};
  while (const NoxiraAudioFrame* f = noxira_engine_acquire_frame()) out = *f;
  return out;
}

TEST(engine_lifecycle_is_idempotent) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  noxira_engine_stop();  // stop before start is a no-op
  CHECK(noxira_engine_is_running() == 0);
  CHECK(noxira_engine_start(&cfg) == 1);
  CHECK(noxira_engine_start(&cfg) == 1);  // second start: still one thread
  CHECK(noxira_engine_is_running() == 1);
  noxira_engine_stop();
  noxira_engine_stop();
  CHECK(noxira_engine_is_running() == 0);
  for (int i = 0; i < 20; ++i) {  // restart cycles must not leak threads
    CHECK(noxira_engine_start(&cfg) == 1);
    noxira_engine_stop();
  }
  noxira_engine_shutdown();
  noxira_engine_shutdown();
  CHECK(noxira_engine_push_pcm(0, nullptr, 0, NOXIRA_PCM_S16) == 0);
  CHECK(noxira_frame_size() == static_cast<int>(sizeof(NoxiraAudioFrame)));
}
REGISTER(engine_lifecycle_is_idempotent);

TEST(engine_source_slots_are_recycled) {
  int ids[NOXIRA_MAX_SOURCES];
  for (int round = 0; round < 50; ++round) {
    for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) {
      ids[i] = noxira_engine_acquire_source();
      CHECK(ids[i] >= 0);
    }
    CHECK(noxira_engine_acquire_source() == -1);  // all slots taken
    for (int i = 0; i < NOXIRA_MAX_SOURCES; ++i) noxira_engine_release_source(ids[i]);
  }
  noxira_engine_release_source(-1);   // invalid ids are ignored
  noxira_engine_release_source(999);
}
REGISTER(engine_source_slots_are_recycled);

TEST(engine_end_to_end_playback) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  cfg.analysis_rate_hz = 60;
  CHECK(noxira_engine_start(&cfg) == 1);
  noxira_engine_set_playback_state(NOXIRA_STATE_PLAYING);

  // Waiting: running with no source.
  std::this_thread::sleep_for(std::chrono::milliseconds(150));
  NoxiraAudioFrame f = latestFrame();
  CHECK(f.state == NOXIRA_STATE_WAITING);

  const int src = noxira_engine_acquire_source();
  CHECK(src >= 0);
  noxira_engine_configure_source(src, 48000, 2);
  const int disc0 = f.discontinuity_count;

  feedRealtime(src, 1000.0, 0.5, 48000, 2, 1.5);
  f = latestFrame();
  CHECK(f.state == NOXIRA_STATE_PLAYING);
  CHECK(f.sample_rate == 48000);
  CHECK(f.source_channels == 2);
  CHECK(f.fft_size == 2048);
  CHECK(f.band_count == 64);
  BandMapper map;
  map.configure(64, 2048, 48000.0f, 20.0f, 20000.0f);
  CHECK(std::abs(argmax(f.bands, 64) - bandOf(map, 1000.0)) <= 1);
  CHECK(f.bands[argmax(f.bands, 64)] > 0.8f);
  CHECK_NEAR(f.rms, 0.5 / std::sqrt(2.0), 0.03);
  CHECK(f.discontinuity_count >= disc0);
  // audio time follows real time (1.5 s fed, some start-up lag allowed)
  CHECK(f.timestamp_us > 1000000 && f.timestamp_us < 1700000);

  // Seek / track change.
  const int disc1 = f.discontinuity_count;
  noxira_engine_flush_source(src);
  feedRealtime(src, 3000.0, 0.4, 48000, 2, 0.6);
  f = latestFrame();
  CHECK(f.discontinuity_count > disc1);
  CHECK(f.timestamp_us < 800000);  // timestamps restart after a flush

  // Sample-rate and channel changes.
  noxira_engine_configure_source(src, 44100, 1);
  feedRealtime(src, 2000.0, 0.4, 44100, 1, 0.7);
  f = latestFrame();
  CHECK(f.sample_rate == 44100);
  CHECK(f.source_channels == 1);
  CHECK(f.stereo_correlation > 0.99f);

  // Pause: state changes and the bars decay to zero without further input.
  noxira_engine_set_playback_state(NOXIRA_STATE_PAUSED);
  std::this_thread::sleep_for(std::chrono::milliseconds(1500));
  f = latestFrame();
  CHECK(f.state == NOXIRA_STATE_PAUSED);
  CHECK(*std::max_element(f.bands, f.bands + 64) == 0.0f);

  // Resume plays again from the buffered position.
  noxira_engine_set_playback_state(NOXIRA_STATE_PLAYING);
  feedRealtime(src, 2000.0, 0.4, 44100, 1, 0.5);
  f = latestFrame();
  CHECK(f.state == NOXIRA_STATE_PLAYING);
  CHECK(*std::max_element(f.bands, f.bands + 64) > 0.5f);

  NoxiraStats stats;
  noxira_engine_get_stats(&stats);
  CHECK(stats.running == 1);
  CHECK(stats.active_sources == 1);
  CHECK(stats.frames_published > 30);
  CHECK(stats.push_calls > 100);
  CHECK(stats.avg_process_us > 0.0f);
  std::printf("    stats: frames=%lld avgDsp=%.1fus maxDsp=%.1fus avgPush=%.2fus maxPush=%.1fus cpu=%.2f%%\n",
              static_cast<long long>(stats.frames_published), stats.avg_process_us,
              stats.max_process_us, stats.avg_push_us, stats.max_push_us, stats.cpu_percent);
  CHECK(stats.avg_push_us < 50.0f);

  noxira_engine_release_source(src);
  noxira_engine_stop();
  // Pushes after stop are ignored and safe.
  const int16_t silence[64] = {};
  CHECK(noxira_engine_push_pcm(src, silence, 32, NOXIRA_PCM_S16) == 0);
}
REGISTER(engine_end_to_end_playback);

TEST(engine_follows_audio_sink_position_instead_of_queued_audio) {
  NoxiraConfig cfg = makeConfig();
  cfg.visualizer_spectrum = 1;
  CHECK(noxira_engine_start(&cfg) == 1);
  noxira_engine_set_playback_state(NOXIRA_STATE_PLAYING);
  const int source = noxira_engine_acquire_source();
  noxira_engine_configure_source(source, 48000, 2);
  std::vector<float> pcm(43200 * 2);
  for (int i = 0; i < 43200; ++i) {
    const double hz = i < 31200 ? 1000.0 : 3000.0;
    pcm[2 * i] = pcm[2 * i + 1] = 0.5f * std::sin(kTwoPi * hz * i / 48000);
  }
  noxira_engine_push_pcm(source, pcm.data(), 43200, NOXIRA_PCM_F32);
  // 900 ms is queued, but only 100 ms is currently audible. Allow the
  // analysis thread and centroid smoother to leave their initial idle state.
  noxira_engine_update_clock(source, 900000, 100000, 1.0f);
  std::this_thread::sleep_for(std::chrono::milliseconds(350));
  const NoxiraAudioFrame frame = latestFrame();
  CHECK(frame.timestamp_us > 300000 && frame.timestamp_us < 600000);
  CHECK_NEAR(frame.centroid_hz, 1000.0, 100.0);
  CHECK(argmax(frame.visualizer_spectrum, frame.visualizer_spectrum_count) ==
        static_cast<int>(std::lround(1000.0 * frame.fft_size / frame.sample_rate)));
  noxira_engine_release_source(source);
  noxira_engine_stop();
}
REGISTER(engine_follows_audio_sink_position_instead_of_queued_audio);

#ifdef __linux__
// Reads a "Key:   value" field of /proc/self/status (threads, VmRSS in kB).
long procStatus(const char* key) {
  FILE* f = std::fopen("/proc/self/status", "r");
  if (!f) return -1;
  char line[256];
  long value = -1;
  const size_t len = std::strlen(key);
  while (std::fgets(line, sizeof(line), f)) {
    if (std::strncmp(line, key, len) == 0) {
      value = std::strtol(line + len, nullptr, 10);
      break;
    }
  }
  std::fclose(f);
  return value;
}

TEST(engine_no_thread_or_memory_leaks) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  cfg.stereo_bands = 1;
  cfg.fft_size = 4096;
  cfg.band_count = 128;
  const int16_t pcm[960 * 2] = {};
  auto cycle = [&] {
    CHECK(noxira_engine_start(&cfg) == 1);
    const int a = noxira_engine_acquire_source();
    noxira_engine_configure_source(a, 48000, 2);
    for (int i = 0; i < 5; ++i) noxira_engine_push_pcm(a, pcm, 960, NOXIRA_PCM_S16);
    std::this_thread::sleep_for(std::chrono::milliseconds(2));
    noxira_engine_release_source(a);
    noxira_engine_stop();
  };
  for (int i = 0; i < 20; ++i) cycle();  // warm up allocator and rings
  const long threadsBefore = procStatus("Threads:");
  const long rssBefore = procStatus("VmRSS:");
  for (int i = 0; i < 300; ++i) cycle();
  const long threadsAfter = procStatus("Threads:");
  const long rssAfter = procStatus("VmRSS:");
  std::printf("    threads %ld -> %ld, RSS %ld kB -> %ld kB after 300 start/stop cycles\n",
              threadsBefore, threadsAfter, rssBefore, rssAfter);
  CHECK(threadsAfter == threadsBefore);
  CHECK(rssAfter - rssBefore < 2048);
}
REGISTER(engine_no_thread_or_memory_leaks);
#endif

std::atomic<int64_t> g_callbackSeq{0};
std::atomic<int> g_callbackCount{0};
void onFrame(int64_t seq) {
  g_callbackSeq.store(seq);
  g_callbackCount.fetch_add(1);
}

TEST(engine_frame_callback_and_rate) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  cfg.analysis_rate_hz = 30;
  g_callbackCount = 0;
  noxira_engine_set_frame_callback(onFrame);
  CHECK(noxira_engine_start(&cfg) == 1);
  const int src = noxira_engine_acquire_source();
  noxira_engine_configure_source(src, 48000, 2);
  noxira_engine_set_playback_state(NOXIRA_STATE_PLAYING);
  feedRealtime(src, 500.0, 0.4, 48000, 2, 2.0);
  const int count = g_callbackCount.load();
  CHECK(count >= 50 && count <= 70);  // ~30 Hz for 2 s

  // The analysis rate can be changed while running.
  cfg.analysis_rate_hz = 60;
  noxira_engine_update_config(&cfg);
  g_callbackCount = 0;
  feedRealtime(src, 500.0, 0.4, 48000, 2, 1.0);
  CHECK(g_callbackCount.load() >= 45);

  noxira_engine_set_frame_callback(nullptr);
  noxira_engine_release_source(src);
  noxira_engine_stop();
}
REGISTER(engine_frame_callback_and_rate);

TEST(engine_idle_when_nothing_to_show) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  CHECK(noxira_engine_start(&cfg) == 1);
  noxira_engine_set_playback_state(NOXIRA_STATE_PAUSED);
  std::this_thread::sleep_for(std::chrono::milliseconds(400));
  NoxiraStats a, b;
  noxira_engine_get_stats(&a);
  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
  noxira_engine_get_stats(&b);
  // Paused and decayed: the thread stops producing frames.
  CHECK(b.frames_published - a.frames_published <= 2);
  noxira_engine_stop();
}
REGISTER(engine_idle_when_nothing_to_show);

TEST(engine_mixes_crossfading_sources) {
  NoxiraConfig cfg;
  noxira_config_default(&cfg);
  CHECK(noxira_engine_start(&cfg) == 1);
  noxira_engine_set_playback_state(NOXIRA_STATE_PLAYING);
  const int a = noxira_engine_acquire_source();
  const int b = noxira_engine_acquire_source();
  noxira_engine_configure_source(a, 48000, 2);
  noxira_engine_configure_source(b, 48000, 2);
  std::thread t([&] { feedRealtime(a, 300.0, 0.25, 48000, 2, 1.2); });
  feedRealtime(b, 3000.0, 0.25, 48000, 2, 1.2);
  t.join();
  const NoxiraAudioFrame f = latestFrame();
  BandMapper map;
  map.configure(64, 2048, 48000.0f, 20.0f, 20000.0f);
  CHECK(f.bands[bandOf(map, 300.0)] > 0.5f);
  CHECK(f.bands[bandOf(map, 3000.0)] > 0.5f);
  noxira_engine_release_source(a);
  noxira_engine_release_source(b);
  noxira_engine_stop();
}
REGISTER(engine_mixes_crossfading_sources);

// ------------------------------------------------------------------ profiling

TEST(profile_dsp_cost) {
  struct Setup {
    int fft, bands;
    bool stereo;
    bool display = false;
  };
  for (Setup su : {Setup{1024, 32, false}, Setup{2048, 64, false}, Setup{4096, 128, false},
                   Setup{4096, 128, true}, Setup{4096, 64, false, true}}) {
    AnalysisPipeline p;
    NoxiraConfig cfg = makeConfig(su.fft, su.bands, 60);
    cfg.stereo_bands = su.stereo;
    cfg.visualizer_spectrum = su.display;
    CHECK(p.configure(cfg, 48000.0f));
    Signal s = makeSignal(4.0);
    std::mt19937 rng(9);
    std::uniform_real_distribution<float> d(-0.3f, 0.3f);
    for (size_t i = 0; i < s.size(); ++i) s.left[i] = s.right[i] = d(rng);
    int frames = 0;
    const auto t0 = std::chrono::steady_clock::now();
    runPipeline(p, s, [&](const NoxiraAudioFrame&, size_t, double) { ++frames; });
    const double us =
        std::chrono::duration<double, std::micro>(std::chrono::steady_clock::now() - t0).count() /
        frames;
    std::printf("    fft=%d bands=%d stereo=%d display=%d: %.1f us/frame "
                "(%.2f%% of one core at 60 Hz)\n",
                su.fft, su.bands, su.stereo, su.display, us, us * 60.0 / 1e4);
    CHECK(us < 2000.0);  // generous: a frame budget at 60 Hz is 16666 us
  }
}
REGISTER(profile_dsp_cost);

}  // namespace

int main(int argc, char** argv) {
  const char* filter = argc > 1 ? argv[1] : nullptr;
  int ran = 0;
  for (const Registered& t : registry()) {
    if (filter && std::strstr(t.name, filter) == nullptr) continue;
    g_current = t.name;
    const int before = g_failures;
    std::printf("[ RUN  ] %s\n", t.name);
    t.fn();
    std::printf("[ %s ] %s\n", g_failures == before ? " OK " : "FAIL", t.name);
    ++ran;
  }
  std::printf("\n%d tests, %d checks, %d failures\n", ran, g_checks, g_failures);
  return g_failures == 0 ? 0 : 1;
}
