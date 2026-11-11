#include "real_fft.h"

#include <cmath>
#include <cstdlib>

#include "dsp_common.h"
extern "C" {
#include "kiss_fftr.h"
}

namespace noxira {

void RealFft::Deleter::operator()(kiss_fftr_state* p) const { std::free(p); }

RealFft::RealFft() = default;
RealFft::~RealFft() = default;

bool RealFft::configure(int size) {
  if (size < 64 || (size & (size - 1)) != 0) return false;
  if (size == size_ && cfg_) return true;
  cfg_.reset(kiss_fftr_alloc(size, 0, nullptr, nullptr));
  if (!cfg_) {
    size_ = 0;
    return false;
  }
  size_ = size;
  window_.resize(static_cast<size_t>(size));
  windowed_.assign(static_cast<size_t>(size), 0.0f);
  spectrum_.assign(static_cast<size_t>(size / 2 + 1) * 2, 0.0f);
  // Periodic Hann window.
  double sum = 0.0;
  for (int i = 0; i < size; ++i) {
    const double w = 0.5 - 0.5 * std::cos(2.0 * kPi * i / size);
    window_[i] = static_cast<float>(w);
    sum += w;
  }
  windowSum_ = static_cast<float>(sum);
  return true;
}

void RealFft::amplitudeSpectrum(const float* samples, float* magnitude) {
  for (int i = 0; i < size_; ++i) windowed_[i] = samples[i] * window_[i];
  kiss_fftr(cfg_.get(), windowed_.data(),
            reinterpret_cast<kiss_fft_cpx*>(spectrum_.data()));
  const float scale = 2.0f / windowSum_;
  const int bins = binCount();
  magnitude[0] = 0.0f;
  for (int k = 1; k < bins; ++k) {
    const float re = spectrum_[2 * k];
    const float im = spectrum_[2 * k + 1];
    magnitude[k] = std::sqrt(re * re + im * im) * scale;
  }
}

}  // namespace noxira
