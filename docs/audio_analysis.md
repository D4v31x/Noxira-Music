# Audio analysis backend

An independent module that turns the PCM Noxira Music is **actually playing**
into normalised analysis data (spectrum, bands, regions, loudness, beats,
percussion-like activity, stereo information) for a visualisation layer. It
contains no UI.

Android is the only implemented platform. On other platforms
`AudioAnalysisService.isSupported` is `false` and the state is `unsupported`.

```
ExoPlayer (just_audio)            native library libnoxira_audio.so
 decoder ─ AudioSink                                         
            └─ processor chain: [silence skip][speed][NoxiraAudioTap]
                                              │ JNI nativePush (direct buffer, no copy)
                                              ▼
                              StereoRing (lock-free SPSC, per source)
                                              │ read by cursor, real-time paced
                                              ▼
                  analysis thread ── AnalysisPipeline (FFT, bands, regions,
                  (only while a         onsets, percussion, smoothing)
                   lease is held)                 │
                                                  ▼
                                 TripleBuffer<NoxiraAudioFrame>  ── callback ──┐
                                              ▲                                 │
                      Dart FFI acquire (zero copy, tear-free) ◄─────────────────┘
                                              │
                    AudioAnalysisService.frames / latestFrame  (AudioFrame views)
```

## Layout

| Part | Location |
| --- | --- |
| C ABI, frame/config structs | `android/app/src/main/cpp/noxira_audio/include/noxira_audio/noxira_audio.h` |
| DSP (FFT, bands, pipeline, PCM fold-down, ring) | `.../noxira_audio/src/dsp/` |
| Engine (sources, thread, triple buffer) | `.../noxira_audio/src/engine/` |
| FFI exports / JNI bridge | `.../noxira_audio/src/ffi/`, `.../src/jni/` |
| KissFFT 131.1.0 (BSD-3, vendored, unmodified) | `.../noxira_audio/third_party/kissfft/` |
| Native tests | `.../noxira_audio/tests/noxira_tests.cpp` |
| Kotlin tap, JNI wrapper, Application hook | `android/app/src/main/kotlin/com/aurorasoftware/music/analysis/`, `NoxiraApplication.kt` |
| just_audio patch | `packages/just_audio/` (see below) |
| Dart API | `lib/shared/services/audio_analysis/` |
| Dart tests | `test/audio_analysis/` |

## PCM acquisition and the just_audio patch

`just_audio` 0.10.6 builds ExoPlayer (media3 1.4.1) with a plain
`DefaultRenderersFactory` and exposes no way to add an `AudioProcessor`.
Audio effects can only be attached by session id (the route the old
`Visualizer` used, which needs `RECORD_AUDIO`).

The least intrusive reliable option is a **local copy of just_audio** in
`packages/just_audio` (wired with `dependency_overrides` in `pubspec.yaml`).
The patch is deliberately tiny:

* new `AudioProcessorHook.java`: a static provider plus a wrapper around
  ExoPlayer's `DefaultAudioProcessorChain` that appends one processor at the
  **end** of the chain, so it sees what is queued to the `AudioTrack`.
  An optional `ClockListener` receives consumed-buffer presentation times
  and the sink's audible playback position through `ForwardingAudioSink`;
* `AudioPlayer.ensurePlayerInitialized()` overrides `buildAudioSink` to call
  the hook. With no provider registered, behaviour is identical to upstream.
* Optional Android equalizer creation failures are logged and bypassed without
  aborting playback. Equalizer control methods return
  `audio_effect_unavailable` when no effect exists; Dart completes its parameter
  future with that error and disables the unavailable effect. Unrelated
  platform errors still propagate. This handles session-time resource failures
  that a startup availability probe cannot predict (FLUTTER-AN).

`NoxiraApplication.onCreate()` registers `NoxiraAudioTap` as the provider
(Application level, so it also works when the audio service starts without an
activity). There is no second playback pipeline or microphone use.
`RECORD_AUDIO` is no longer declared by the app.

**Maintenance:** when updating `just_audio`, re-apply the changes above to
the new version (diff `packages/just_audio/android/.../AudioPlayer.java`
against upstream) or drop the override once upstream offers a hook. Keep the
`androidx.media3:media3-exoplayer` version in `android/app/build.gradle` equal
to the one just_audio uses.

### The tap (`NoxiraAudioTap`)

A pass-through `BaseAudioProcessor`. Per buffer it performs **one memcpy**
(unavoidable: ExoPlayer's contract lets the codec reuse its buffer once the
processor consumed it) and one non-blocking JNI call that returns immediately
while analysis is off. No disk, network or blocking work; allocation only in
`onConfigure` (format change). It:

* is inactive in the chain for non-PCM formats;
* maps `onConfigure` → `configureSource` (sample rate / channels), `onFlush` →
  `flushSource` (seek, track change), `onQueueEndOfStream` → `endSource`,
  `onReset` → `releaseSource` (slots never leak; there are 4);
* accepts 8/16/24/32-bit integer and float PCM, any channel count. For more
  than two channels the engine folds down (centre −3 dB, surrounds/heights
  −6 dB, LFE dropped, power-preserving).

## Threads and real-time behaviour

* **Audio thread** (ExoPlayer playback thread): `noxira_engine_push_pcm`. It
  converts to float stereo into a lock-free ring; no locks, allocation or FFT.
* **Analysis thread**: created by `start`, joined by `stop`. Runs at the
  configured rate (10–120 Hz, default 60), paced by wall clock. When nothing is
  audible and everything has decayed to zero it **stops producing** frames and
  wakes only every 100 ms; with no lease it does not exist.
* **Dart main isolate**: receives a `NativeCallable.listener` notification per
  frame and reads the frame zero-copy (triple buffer: the writer never touches
  the buffer the reader holds, so frames are never torn). No FFT runs in Dart.

**Playback sync.** The tap sits before the AudioTrack's queue, so reading its
newest PCM can run ahead of the sound. The sink wrapper reports queued media
time, audible media time and playback speed without changing the sink's
behavior. Native atomics anchor each source's analysis cursor to that clock.
Seeks/flushes invalidate the old anchor; reopening/background-resuming drops
uncaptured history. Hosts without sink-clock metadata retain the original
250 ms queue estimate. `latencyCompensationMs` adds an optional output delay.
Sources with different sample rates are not mixed; the newest stream wins.
During a crossfade both players' PCM is mixed pre-volume, so their fade
curves are not reflected.

## Lifecycle

* `AudioAnalysisService.requestAnalysis()` returns a **lease**; the first lease
  starts the native thread, the last `release()` stops it. Releasing twice is
  harmless, `start`/`stop`/`shutdown` are idempotent.
* The newest lease's config wins; releasing it restores the previous one.
* In the background (`paused`/`hidden`/`detached`) the engine stops unless a
  lease was created with `keepAliveInBackground: true`; it restarts on resume.
* `bindPlayer(player)` (called from `AudioPlayerService._bindCorePlayerListeners`,
  so crossfade player swaps are followed) maps just_audio state to
  playing / paused / buffering / ended. Audio-focus loss shows up as `paused`.
* Creating the service resets any native state left by a previous isolate
  (hot restart, recreated engine). Native resources are process-wide and
  survive activity recreation.
* Native memory: each of the 4 source slots owns a 64 Ki-frame ring (~0.5 MB),
  allocated on first use and pooled for the process lifetime. Tested: 300
  start/stop cycles keep the thread count and RSS flat.

## Dart API

```dart
final service = AudioAnalysisService.instance;
final lease = service.requestAnalysis(
  config: const AudioAnalysisConfig(fftSize: 2048, bandCount: 64, analysisRateHz: 60),
);
final sub = service.frames.listen((AudioFrame f) {
  f.bands;        // Float32List view, 0..1, log spaced
  f.bass;         // region energy 0..1
  if (f.isBeat) {/* ... */}
});
// later
await sub.cancel();
lease.release();
```

`frames` delivers a pool of three reused `AudioFrame` objects backed by native
memory: **valid until the next frame**; use `frame.snapshot()` to keep one.
`service.latestFrame` is the newest frame, `service.readStats()` returns
counters (DSP time, push cost, CPU %, overruns).
`--dart-define=NOXIRA_ANALYSIS_DIAG=true` logs a summary and the counters every
2 s (`AudioAnalysisDiagnostics`, no UI).

## AudioFrame reference

Normalised values are 0..1 unless stated. Time-based values are independent of
the analysis rate. Event flags are true for exactly one frame.

| Field | Range | Meaning |
| --- | --- | --- |
| `state` | enum | inactive, waiting (no PCM yet), playing, paused, buffering, ended, unsupported |
| `timestampUs` | µs | analysed audio time since the last discontinuity (not the player position) |
| `sequence` | int | +1 per frame |
| `discontinuityCount` | int | +1 on seek / track change / flush |
| `sampleRate`, `sourceChannels` | Hz, int | of the analysed stream (0 when unknown) |
| `fftSize`, `bandCount`, `spectrumCount`, `waveformCount` | int | valid entries of the arrays |
| `bands`, `bandsLeft`, `bandsRight`, `bandPeaks` | 0..1 | log-spaced band levels (32/64/128), per-channel bands (= `bands` unless `stereoBands`), peak-hold markers |
| `spectrum` | 0..1 | linear-frequency normalised dB, entry *i* centred at `(i+0.5)·Nyquist/count` Hz |
| `visualizerSpectrum` | linear capture amplitude | optional floating-point Hann spectrum with shared capture gain; bin *k* is `k·sampleRate/fftSize` Hz |
| `waveformLeft/Right` | −1..1 | newest window, peak-preserving decimation |
| `subBass`…`high`, `regions`, `regionPeaks` | 0..1 | seven regions (default 20–60, 60–250, 250–500, 500–2k, 2–4k, 4–8k, 8–20 kHz; configurable) |
| `rms`, `peak`, `peakHold` | linear FS | both channels, newest ~21 ms; hold/decay |
| `energy` | 0..1 | overall loudness vs. recent history |
| `centroidHz`, `centroid` | Hz, 0..1 | spectral centroid (0 when silent), log 20 Hz–20 kHz scale |
| `flux` | 0..1 | spectral flux (band-based, normalised) |
| `zeroCrossingRate` | 0..1 | sign changes per sample (≈0.5 for noise) |
| `transient` | 0..1 | transient strength, decays after a hit |
| `isOnset`, `onsetStrength` | bool, 0..1 | adaptive-threshold onset on band flux |
| `isBeat`, `bpm`, `beatConfidence` | bool, BPM, 0..1 | low-frequency onsets (≥0.27 s apart); tempo = median of recent intervals; BPM 0 when unknown |
| `kick`, `snare`, `hihat`, `percussion` | 0..1 | activity: jumps on a hit, then decays (140 / 110 / 50 ms) |
| `isKickHit`, `isSnareHit`, `isHihatHit` | bool | hit in this frame |
| `bassActivity` | 0..1 | sustained sub-bass + bass energy |
| `stereoWidth` | 0..1 | side/(mid+side) |
| `stereoCorrelation` | −1..1 | L/R correlation (0 if one channel is silent) |
| `stereoBalance` | −1..1 | left … right |
| `rmsLeft/Right`, `peakLeft/Right` | linear FS | per channel |
| `isSilent` | bool | input below the noise floor (also while paused/ended) |

The exact byte layout is pinned by `static_assert`s (native) and the Dart
layout test; `noxira_frame_size()` is checked when the library loads. ABI v3
includes up to 2048 floats for `visualizerSpectrum`, with its active count
at byte offset 60 (18688 bytes per native frame). It is a zero-copy view,
not a platform-channel transfer.

## DSP summary

* **FFT**: KissFFT real FFT, Hann window, amplitude-calibrated so a sine of
  amplitude A at a bin centre reads A. Left and right are transformed and
  power-averaged (no phase cancellation, so out-of-phase content is still
  seen). Sizes 1024/2048/4096; any sample rate (tables rebuild on change).
* **Bands**: log-spaced between `minHz` and `maxHz` (clamped to 98 % Nyquist),
  integrated with fractional bin weights; bands narrower than one bin
  interpolate neighbours (low bands share information at small FFT sizes).
* **Normalisation**: levels in dBFS; below `noiseFloorDb` (soft 6 dB gate) →
  0, never amplified. The reference follows recent peaks with **6 dB of
  headroom**, instant rise and a 2.5 dB/s fall. It never falls below -18 dBFS,
  limiting gain in quiet passages. The default 48 dB window maps levels to
  0..1: a sustained strongest band reaches 0.875, not full scale. All bands
  use the **same reference** (`globalReferenceMix = 1`), preserving level
  differences rather than boosting every quiet band toward its own peak.
  Defaults are neutral: no sensitivity tilt, no extra level floor, linear
  contrast and no delayed normalization attack. Optional per-band gain,
  reference mixing and shaping remain available to explicit API consumers.
* **Smoothing**: exponential attack/release with `exp(-dt/τ)`, peak hold +
  linear decay; everything uses the real elapsed time. One output smoother
  follows normalization (40 ms attack, 200 ms release by default). Silence
  decays with that release constant without updating the gain reference.
  There is no native valley-filling or additional Dart-side band smoothing.
* **Silence** is judged over the whole FFT window, so short transients still
  count. Values below 0.001 snap to exactly 0 and the thread goes idle.
* **Onsets / percussion**: adaptive threshold (mean + k·σ of ~0.7 s of
  history, refractory period) on spectral-flux curves: full band (log bands),
  30–120 Hz (kick; leakage from a louder body just above is subtracted),
  150–350 Hz × 1.5–6 kHz (snare), 6–16 kHz (hi-hat). Clocks keep running
  during silence.

**Important:** kick/snare/hi-hat output is *kick-/snare-/hi-hat-like energy
bursts*, a DSP heuristic. Frequency bands alone cannot identify instruments or
vocals. `AnalysisPipeline` is a self-contained stage, so an ML classifier or
source separator can later be added beside it and feed extra fields without
changing acquisition or delivery.

## Testing

```bash
# native DSP + engine tests (no framework needed)
cmake -S android/app/src/main/cpp -B build/noxira_host \
      -DCMAKE_BUILD_TYPE=Release -DNOXIRA_BUILD_TESTS=ON -G Ninja
cmake --build build/noxira_host
ctest --test-dir build/noxira_host --output-on-failure   # or ./build/noxira_host/noxira_tests [filter]

# Dart: frame layout/API tests + FFI/lifecycle integration against the host library
flutter test test/audio_analysis

# Display mapping and rendered contrast at phone/tablet sizes
flutter test test/spectrum_analyzer_test.dart test/visualizer_colors_test.dart \
    test/services/artwork_palette_test.dart

# Optional-effect failure and queue/settings startup cancellation
flutter test test/services/equalizer_fallback_test.dart \
    test/services/audio_settings_recovery_test.dart
```

Native tests cover FFT amplitude/bin accuracy for 1024/2048/4096 at
44.1/48 kHz, log band distribution, silence, sub-noise-floor input, sines,
mixed tones and regions, stereo (mono, L/R only, out of phase, wide),
normalisation of loud/quiet/faint signals, shared-reference level differences,
headroom over sustained signals, quiet-band rejection, exact release decay,
rate-independent smoothing, peak
hold, kick/snare/hi-hat/click/steady-tone detection, tempo, seek handling,
sample rates 22–96 kHz, bounded/finite outputs, frequency-dependent
sensitivity, PCM conversion (S16/U8/S24/S32/F32, mono, 5.1/7.1.4 fold-down),
ring buffer wrap/overrun and a producer/consumer stress test, triple-buffer
tear-freeness, and engine lifecycle (idempotent start/stop, slot recycling,
flush/seek, sample-rate and channel changes, pause/resume, crossfade mixing,
callbacks, idle behaviour, thread/RSS leak check). Also run under
`-D_GLIBCXX_ASSERTIONS -D_FORTIFY_SOURCE=2 -fstack-protector-all` with
`MALLOC_CHECK_=3 MALLOC_PERTURB_=165`.

## Performance

Host (x86-64, Release) per analysis frame: 1024/32 bands ≈ 27–37 µs,
2048/64 ≈ 34–42 µs, 4096/128 ≈ 65–79 µs, 4096/128 + stereo bands ≈ 84–123 µs
(0.2–0.7 % of one core at 60 Hz). The PCM hand-off on the audio thread costs
≈ 2 µs per buffer. On a Galaxy S25 Ultra (debug build, observed in the
diagnostics log while idle/paused): DSP ≈ 57–74 µs per frame, push ≈ 8 µs,
analysis-thread CPU ≈ 0.01 %.

The current visualiser configuration (4096 FFT, 64 generic bands, full display
spectrum enabled) measured 82 µs/frame on the host, approximately 0.49 % of
one core at 60 Hz. This is native DSP cost, not a Flutter rendering benchmark.

## Limitations and known gaps

* Normal stereo playback, seeking and pause/resume were checked on the S25
  Ultra; the user confirmed clean sound and working transitions. Full
  crossfade, long-running/background interruption testing and 12-channel
  Dolby playback still require hardware coverage. ASan/TSan could not be
  run because their runtimes are not installed on the development machine.
* Offload and passthrough playback (e.g. E-AC-3 passed to an HDMI/receiver
  sink) bypass ExoPlayer's audio processors: no PCM, state stays `waiting`.
* The audible clock is supplied by the app's patched AudioSink; other hosts
  without that metadata fall back to a 250 ms queue estimate. Capture begins
  when the visualiser opens, so queued audio not yet observed by the tap
  cannot be reconstructed at first activation. The display waits for actual
  samples rather than synthesizing an animation.
* Frames are analysed before the player's volume stage; user/crossfade volume
  is not reflected.
* Up to 4 simultaneous PCM sources; sources with different sample rates are not
  mixed.
* iOS/other platforms: no backend (`unsupported`).
* Legacy Android FFT/file-analysis code remains as a reference, but the
  current visualiser does not call it. `RECORD_AUDIO` and the onboarding
  microphone permission request have been removed.

## Consumer: the music visualiser

`MusicVisualizerScreen` requests a foreground analysis lease with
`fftSize: 4096, visualizerSpectrum: true`. It consumes the native floating-point
Hann spectrum, preserving spectral detail instead of emulating Android's old
8-bit, 1024-point FFT. At 48 kHz, bin spacing is 11.72 Hz instead of 46.88 Hz.
This matters especially for rolling low notes and pitch changes in buildups.
The same FFTs feed generic bands, measurements and component estimates; no
additional FFT or file decoder is needed for the screen.

The approved dB gate and gain curve in `SpectrumAnalyzer` remain the **level
reference**, not a requirement to copy the old animation. Fractional FFT-bin
overlaps and power-weighted band aggregation make movement between adjacent
frequency bands continuous. One time-based attack/release stage follows the
signal. There are no kick-specific speed overrides, flashes or instrument
indicators: melodic, bass, vocal and percussion content all follow the same
full-spectrum processing. Component estimates remain independently available
through `AudioFrame`.

There is no microphone, Android Visualizer effect, Dolby file decode or
procedural fallback in this screen's active path. Waiting/unavailable
capture is shown explicitly. A silent signal stays silent.

### Calibration evidence

The initial capture-unit compatibility prototype was checked against Android's published
[Visualizer FFT conversion](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/media/jni/audioeffect/Visualizer.cpp)
and [fixed FFT](https://android.googlesource.com/platform/system/media/+/refs/heads/main/audio_utils/fixedfft.cpp).
Across 10220 synthetic FFT bins the mean magnitude error was 0.213 capture
units (maximum 1.414), with on-bin sine peaks matching exactly. That prototype
was then replaced by the full-resolution floating-point spectrum to avoid
the old quantization and low-frequency snapping.

Before the full-resolution change, both paths ran concurrently on the same
user-approved 48 kHz stereo reference song on the S25 Ultra. Across 152
matched measurements after startup:

| Metric | Old capture | PCM capture |
| --- | --- | --- |
| Mean displayed band level | 0.27238 | 0.27166 |
| 90th percentile band level | 0.462 | 0.461 |
| Bands above 0.9 | 0 % | 0 % |

Mean difference between the 64 long-term band profiles was 0.00288 on the
0..1 scale. This established a level baseline, not a target for identical
motion.

The current 4096-point path was then measured offline on the same reference
song's first 40 seconds: mean band level 0.177, 90th percentile 0.371, no
values above 0.9. It suppresses quantization/leakage noise rather than
boosting it to reproduce the previous mean height. Synthetic descending
220–60 Hz and 2400–600 Hz glides are tested both natively and through the
display mapping for correct frequency tracking and continuous movement.
Clock tests verify that analysis reads audible rather than queued audio.

After installation on the S25 Ultra, the user confirmed that smooth rolls
and note movement are visible and bar heights are sensible.

The display selects a chromatic accent from the extracted artwork palette,
ranking chroma, saturation and hue separation from the dominant color rather
than using a fixed palette index or favoring pale swatches for brightness.
The existing background service also extracts up to 24 accent swatches in its
worker isolate, retaining small colored details omitted from the four mesh
colors. Its original background palette is unchanged, and both are cached per
track. Swatches covering less than 0.5% of the quantized image are ignored.
Brightness corrections preserve hue and saturation;
gradient highlights stay in that same artwork hue instead of fading to white.
Dark underpainting follows each mark's exact geometry, with no outward black
stroke or border. It stabilizes translucent colors without outlining the bars.
Primary marks, including gradient bar bases, maintain at least 3:1 contrast
against those backings instead of being bleached to contrast with hypothetical
white artwork. The artwork retains its 60% black scrim. Monochrome or
missing artwork stays neutral. This changes neither signal levels nor smoothing;
decorative fills and glows are not used to guarantee visibility.
On-device inspection of all nine modes on the S25 Ultra verified that "Hole"
uses the cover's red detail rather than its muted blue-gray body.
