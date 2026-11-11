// Maps a linear-frequency amplitude spectrum onto logarithmically spaced
// bands and onto a small number of fixed-edge frequency regions.
#ifndef NOXIRA_DSP_BAND_MAPPER_H_
#define NOXIRA_DSP_BAND_MAPPER_H_

#include <vector>

namespace noxira {

class BandMapper {
 public:
  // Builds `bandCount` log-spaced bands between minHz and maxHz (maxHz is
  // limited to 98% of Nyquist). `fftSize` is the FFT length in samples.
  void configure(int bandCount, int fftSize, float sampleRate, float minHz,
                 float maxHz);

  int bandCount() const { return static_cast<int>(bands_.size()); }
  float centerHz(int band) const { return bands_[band].centerHz; }
  float lowHz(int band) const { return bands_[band].lowHz; }
  float highHz(int band) const { return bands_[band].highHz; }

  // `magnitude` has fftSize/2 + 1 amplitude values; `out` gets bandCount()
  // linear amplitudes. Bands narrower than one FFT bin interpolate between the
  // neighbouring bins, so very low bands share information at small FFT sizes.
  void map(const float* magnitude, float* out) const;

 private:
  struct Band {
    float lowHz, highHz, centerHz;
    float lowBin, highBin;  // fractional bin coordinates
    int firstBin, lastBin;  // inclusive integer bin range for wide bands
    bool narrow;
  };
  std::vector<Band> bands_;
  int binCount_ = 0;
};

// Energy in fixed frequency regions (sub-bass, bass, ...).
class RegionMapper {
 public:
  // `edgesHz` holds `regionCount + 1` ascending edges.
  void configure(const float* edgesHz, int regionCount, int fftSize,
                 float sampleRate);
  int regionCount() const { return static_cast<int>(regions_.size()); }

  // Writes the band-limited amplitude of each region: the RMS-equivalent
  // amplitude of the bins inside it, so a sine of amplitude A inside a region
  // reads about A.
  void map(const float* magnitude, float* out) const;

 private:
  struct Region {
    int firstBin, lastBin;  // inclusive, may be empty (first > last)
  };
  std::vector<Region> regions_;
  int binCount_ = 0;
};

}  // namespace noxira

#endif  // NOXIRA_DSP_BAND_MAPPER_H_
