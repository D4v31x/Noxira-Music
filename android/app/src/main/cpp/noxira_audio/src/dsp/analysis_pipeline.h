// The DSP core: turns one window of stereo PCM into a NoxiraAudioFrame.
//
// It is deterministic and has no dependency on threads, clocks or Android, so
// it can be unit tested with synthetic signals. All time-dependent behaviour
// (smoothing, peak hold, decay, onset refractory periods) uses the `dt`
// argument, never a per-frame constant.
#ifndef NOXIRA_DSP_ANALYSIS_PIPELINE_H_
#define NOXIRA_DSP_ANALYSIS_PIPELINE_H_

#include <vector>

#include "band_mapper.h"
#include "dsp_common.h"
#include "noxira_audio/noxira_audio.h"
#include "real_fft.h"
#include "visualizer_spectrum.h"

namespace noxira {

// Fills `out` with the default configuration.
void fillDefaultConfig(NoxiraConfig* out);

// Clamps every field of `config` to a supported value.
void sanitizeConfig(NoxiraConfig* config);

class AnalysisPipeline {
 public:
  AnalysisPipeline();

  // (Re)builds all tables for `config` (sanitised internally) and
  // `sampleRate`. Allocates; never call it from the audio thread. Clears state.
  bool configure(const NoxiraConfig& config, float sampleRate);

  const NoxiraConfig& config() const { return config_; }
  float sampleRate() const { return sampleRate_; }
  int windowSize() const { return config_.fft_size; }
  bool configured() const { return configured_; }

  // Analyses `windowSize()` samples per channel. `dt` is the elapsed time
  // since the previous frame in seconds. Fills every analysis field of `out`
  // (not timestamp, sequence or state, which belong to the engine).
  void process(const float* left, const float* right, double dt, NoxiraAudioFrame* out);

  // Advances the smoothers towards silence without any input (paused, ended,
  // waiting). Cheap: no FFT.
  void decay(double dt, NoxiraAudioFrame* out);

  // True when every output has decayed to (almost) zero.
  bool idle() const { return idle_; }

  // Marks a stream discontinuity (seek, track change): keeps the smoothed
  // outputs so bars don't jump, but drops the spectral history so the jump is
  // not reported as an onset.
  void softReset();

  // Clears everything, including normalisation references.
  void reset();

 private:
  void finish(double dt, NoxiraAudioFrame* out, bool silent);
  void clearTargets();
  float groupFlux(int firstBin, int lastBin) const;
  void applyContrast(std::vector<float>& values) const;
  void updateBandOutputs(float dt, bool stereo);

  NoxiraConfig config_{};
  float sampleRate_ = 48000.0f;
  bool configured_ = false;
  bool idle_ = true;
  int bins_ = 0;       // fftSize / 2 + 1
  int bandCount_ = 0;
  int spectrumCount_ = 0;
  int spectrumGroup_ = 1;
  int waveformCount_ = 0;
  int waveformGroup_ = 1;

  RealFft fftLeft_, fftRight_;
  BandMapper bandMapper_;
  RegionMapper regionMapper_;
  DynamicNormalizer bandNorm_, regionNorm_, energyNorm_;

  // Per-frame scratch (allocated in configure()).
  std::vector<float> magMono_, magLeft_, magRight_;  // magMono_ = combined channels
  std::vector<float> bandLin_, bandDb_, bandNormOut_, bandGate_, tilt_;
  std::vector<float> bandLinL_, bandDbL_, bandNormL_, bandGateL_, bandLinR_, bandDbR_,
      bandNormR_, bandGateR_;
  std::vector<float> regionLin_, regionDb_, regionNormOut_, regionGate_;
  std::vector<float> spectrumDb_, spectrumTarget_;
  std::vector<float> compressed_, prevCompressed_, compressedBands_, prevBands_;

  // Smoothed state.
  std::vector<float> bandSmooth_, bandSmoothL_, bandSmoothR_, bandPeak_, bandPeakTimer_;
  std::vector<float> regionSmooth_, regionPeak_, regionPeakTimer_;
  std::vector<float> spectrumSmooth_;
  float energySmooth_ = 0.0f;
  float peakHold_ = 0.0f, peakHoldTimer_ = 0.0f;

  // Targets for this frame (bands etc. live in the *NormOut_ arrays).
  float targetEnergy_ = 0.0f;

  // Instantaneous measurements of the current frame.
  float rmsMono_ = 0.0f, peakMono_ = 0.0f, rmsL_ = 0.0f, rmsR_ = 0.0f, peakL_ = 0.0f,
        peakR_ = 0.0f, zcr_ = 0.0f, fluxRaw_ = 0.0f, transientRaw_ = 0.0f;
  float stereoWidth_ = 0.0f, stereoCorr_ = 1.0f, stereoBalance_ = 0.0f;
  float onsetStrength_ = 0.0f;
  bool evOnset_ = false, evBeat_ = false, evKick_ = false, evSnare_ = false,
       evHat_ = false;
  float kickStrength_ = 0.0f, snareStrength_ = 0.0f, hatStrength_ = 0.0f;

  // Signal features / detectors.
  OnsetTracker onsetAll_, onsetKick_, onsetSnare_, onsetHat_, onsetBeat_;
  float fluxRunMax_ = 0.05f, kickRunMax_ = 0.05f, snareLowRunMax_ = 0.05f,
        snareHighRunMax_ = 0.05f, hatRunMax_ = 0.05f;
  float fluxOut_ = 0.0f, transientOut_ = 0.0f;
  float kickAct_ = 0.0f, snareAct_ = 0.0f, hatAct_ = 0.0f;
  float slowRms_ = 0.0f;
  float centroidHz_ = 0.0f;
  float widthS_ = 0.0f, corrS_ = 0.0f, balanceS_ = 0.0f;
  float beatConfidence_ = 0.0f, bpm_ = 0.0f;
  double sinceBeat_ = 1e6;
  double beatClock_ = 0.0;
  double lastBeatTime_ = -1.0;
  float intervals_[16] = {};
  int intervalCount_ = 0, intervalHead_ = 0;
  bool havePrev_ = false;
  int skipFlux_ = 0;

  // Bin ranges of the percussion groups.
  int kickLo_ = 1, kickHi_ = 1, snareLowLo_ = 1, snareLowHi_ = 1, snareHighLo_ = 1,
      snareHighHi_ = 1, hatLo_ = 1, hatHi_ = 1, beatLo_ = 1, beatHi_ = 1;
};

}  // namespace noxira

#endif  // NOXIRA_DSP_ANALYSIS_PIPELINE_H_
