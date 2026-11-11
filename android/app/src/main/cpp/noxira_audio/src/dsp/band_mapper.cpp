#include "band_mapper.h"

#include <algorithm>
#include <cmath>

namespace noxira {

void BandMapper::configure(int bandCount, int fftSize, float sampleRate,
                           float minHz, float maxHz) {
  binCount_ = fftSize / 2 + 1;
  const float binHz = sampleRate / static_cast<float>(fftSize);
  const float nyquistLimit = sampleRate * 0.5f * 0.98f;
  const float lo = std::max(minHz, 1.0f);
  const float hi = std::min(std::max(maxHz, lo * 1.5f), nyquistLimit);
  const float ratio = hi / lo;

  bands_.assign(static_cast<size_t>(bandCount), Band{});
  for (int i = 0; i < bandCount; ++i) {
    Band& b = bands_[i];
    b.lowHz = lo * std::pow(ratio, static_cast<float>(i) / bandCount);
    b.highHz = lo * std::pow(ratio, static_cast<float>(i + 1) / bandCount);
    b.centerHz = std::sqrt(b.lowHz * b.highHz);
    b.lowBin = b.lowHz / binHz;
    b.highBin = b.highHz / binHz;
    b.narrow = (b.highBin - b.lowBin) < 1.0f;
    // A bin k covers [k - 0.5, k + 0.5] in bin coordinates.
    b.firstBin = std::max(1, static_cast<int>(std::floor(b.lowBin + 0.5f)));
    b.lastBin = std::min(binCount_ - 1,
                         std::max(b.firstBin, static_cast<int>(std::ceil(b.highBin - 0.5f))));
  }
}

void BandMapper::map(const float* magnitude, float* out) const {
  const int n = static_cast<int>(bands_.size());
  for (int i = 0; i < n; ++i) {
    const Band& b = bands_[i];
    if (b.narrow) {
      const float c = std::min(std::max(0.5f * (b.lowBin + b.highBin), 1.0f),
                               static_cast<float>(binCount_ - 2));
      const int k0 = static_cast<int>(c);
      const float f = c - static_cast<float>(k0);
      out[i] = magnitude[k0] * (1.0f - f) + magnitude[k0 + 1] * f;
      continue;
    }
    double power = 0.0, weight = 0.0;
    float peak = 0.0f;
    for (int k = b.firstBin; k <= b.lastBin; ++k) {
      const float overlap = std::min(b.highBin, static_cast<float>(k) + 0.5f) -
                            std::max(b.lowBin, static_cast<float>(k) - 0.5f);
      if (overlap <= 0.0f) continue;
      const float m = magnitude[k];
      power += static_cast<double>(overlap) * m * m;
      weight += overlap;
      peak = std::max(peak, m);
    }
    const float rms = weight > 0.0 ? static_cast<float>(std::sqrt(power / weight)) : 0.0f;
    out[i] = 0.6f * rms + 0.4f * peak;
  }
}

void RegionMapper::configure(const float* edgesHz, int regionCount, int fftSize,
                             float sampleRate) {
  binCount_ = fftSize / 2 + 1;
  const float binHz = sampleRate / static_cast<float>(fftSize);
  regions_.assign(static_cast<size_t>(regionCount), Region{});
  for (int i = 0; i < regionCount; ++i) {
    int first = static_cast<int>(std::ceil(edgesHz[i] / binHz));
    int last = static_cast<int>(std::ceil(edgesHz[i + 1] / binHz)) - 1;
    first = std::max(first, 1);
    last = std::min(last, binCount_ - 1);
    if (last < first) {
      // Region narrower than a bin: use the bin nearest to its centre.
      const float centre = 0.5f * (edgesHz[i] + edgesHz[i + 1]) / binHz;
      first = last = std::min(std::max(static_cast<int>(std::lround(centre)), 1),
                              binCount_ - 1);
    }
    regions_[i] = {first, last};
  }
}

void RegionMapper::map(const float* magnitude, float* out) const {
  // Equivalent noise bandwidth of the Hann window: a sine spreads over its
  // neighbouring bins so that the summed power is 1.5 * A^2.
  constexpr float kHannEnbw = 1.5f;
  for (size_t i = 0; i < regions_.size(); ++i) {
    double power = 0.0;
    for (int k = regions_[i].firstBin; k <= regions_[i].lastBin; ++k) {
      power += static_cast<double>(magnitude[k]) * magnitude[k];
    }
    out[i] = static_cast<float>(std::sqrt(power / kHannEnbw));
  }
}

}  // namespace noxira
