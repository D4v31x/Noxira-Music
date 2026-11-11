#include "visualizer_spectrum.h"

#include <algorithm>
#include <cmath>

namespace noxira {

void visualizerSpectrum(const float* amplitude, const float* left, const float* right,
                        int fftSize, float* magnitude) {
  float peak = 0.0f;
  for (int i = 0; i < fftSize; ++i) {
    peak = std::max({peak, std::fabs(left[i]), std::fabs(right[i])});
  }
  // Capture's 8/N transform gives an on-bin tone four times its signed-8-bit
  // amplitude. Preserve those units without quantization or per-bin shifts.
  const float scale = 0.99f * (128.0f * 4.0f) / std::max(peak, 0.01f);
  magnitude[0] = 0.0f;
  for (int k = 1; k < fftSize / 2; ++k) {
    magnitude[k] = amplitude[k] * scale;
  }
}

}  // namespace noxira
