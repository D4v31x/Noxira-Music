// Real-input FFT (KissFFT) with a Hann window and amplitude calibration.
#ifndef NOXIRA_DSP_REAL_FFT_H_
#define NOXIRA_DSP_REAL_FFT_H_

#include <memory>
#include <vector>

struct kiss_fftr_state;

namespace noxira {

class RealFft {
 public:
  RealFft();
  ~RealFft();
  RealFft(const RealFft&) = delete;
  RealFft& operator=(const RealFft&) = delete;

  // Prepares for `size` real samples (power of two). Allocates; call off the
  // audio thread. Returns false for an unsupported size.
  bool configure(int size);

  int size() const { return size_; }
  int binCount() const { return size_ / 2 + 1; }

  // Windows `samples` (size() values) and writes the amplitude spectrum to
  // `magnitude` (binCount() values): a sine of amplitude A at a bin centre
  // reads A. Bin 0 (DC) is zeroed.
  void amplitudeSpectrum(const float* samples, float* magnitude);


 private:
  int size_ = 0;
  float windowSum_ = 1.0f;
  std::vector<float> window_;
  std::vector<float> windowed_;
  std::vector<float> spectrum_;  // interleaved re/im, binCount() complex values
  struct Deleter {
    void operator()(kiss_fftr_state* p) const;
  };
  std::unique_ptr<kiss_fftr_state, Deleter> cfg_;
};

}  // namespace noxira

#endif  // NOXIRA_DSP_REAL_FFT_H_
