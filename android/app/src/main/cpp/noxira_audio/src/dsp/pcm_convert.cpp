#include "pcm_convert.h"

#include <algorithm>
#include <cmath>
#include <cstring>

namespace noxira {

namespace {

constexpr int kChunkFrames = 256;
constexpr int kMaxFoldChannels = 32;

inline float readSample(const uint8_t* p, int encoding) {
  switch (encoding) {
    case NOXIRA_PCM_S16: {
      int16_t v;
      std::memcpy(&v, p, sizeof(v));
      return static_cast<float>(v) * (1.0f / 32768.0f);
    }
    case NOXIRA_PCM_U8:
      return (static_cast<float>(p[0]) - 128.0f) * (1.0f / 128.0f);
    case NOXIRA_PCM_S24: {
      int32_t v = static_cast<int32_t>(p[0]) | (static_cast<int32_t>(p[1]) << 8) |
                  (static_cast<int32_t>(p[2]) << 16);
      if (v & 0x800000) v |= ~0xFFFFFF;
      return static_cast<float>(v) * (1.0f / 8388608.0f);
    }
    case NOXIRA_PCM_S32: {
      int32_t v;
      std::memcpy(&v, p, sizeof(v));
      return static_cast<float>(v) * (1.0f / 2147483648.0f);
    }
    case NOXIRA_PCM_F32: {
      float v;
      std::memcpy(&v, p, sizeof(v));
      return v;
    }
    default:
      return 0.0f;
  }
}

struct FoldGains {
  float left[kMaxFoldChannels];
  float right[kMaxFoldChannels];
};

FoldGains makeFold(int channels) {
  FoldGains g{};
  if (channels <= 2) return g;
  float sumSq = 0.0f;
  for (int c = 0; c < channels && c < kMaxFoldChannels; ++c) {
    float l = 0.0f, r = 0.0f;
    if (c == 0) {
      l = 1.0f;
    } else if (c == 1) {
      r = 1.0f;
    } else if (c == 2) {
      l = r = 0.7071f;
    } else if (c == 3) {
      // LFE is dropped: it carries no extra information for a visual spectrum.
    } else if (c % 2 == 0) {
      l = 0.5f;
    } else {
      r = 0.5f;
    }
    g.left[c] = l;
    g.right[c] = r;
    sumSq += l * l;
  }
  const float norm = 1.0f / std::sqrt(std::max(sumSq, 1.0f));
  for (int c = 0; c < channels && c < kMaxFoldChannels; ++c) {
    g.left[c] *= norm;
    g.right[c] *= norm;
  }
  return g;
}

}  // namespace

int bytesPerSample(int encoding) {
  switch (encoding) {
    case NOXIRA_PCM_S16: return 2;
    case NOXIRA_PCM_U8: return 1;
    case NOXIRA_PCM_S24: return 3;
    case NOXIRA_PCM_S32: return 4;
    case NOXIRA_PCM_F32: return 4;
    default: return 0;
  }
}

void pushPcm(StereoRing& ring, const void* data, int frames, int channels,
             int encoding) {
  const int bps = bytesPerSample(encoding);
  if (bps == 0 || channels <= 0 || frames <= 0 || data == nullptr) return;
  const int usable = std::min(channels, kMaxFoldChannels);
  const FoldGains fold = makeFold(usable);
  const uint8_t* bytes = static_cast<const uint8_t*>(data);
  const size_t frameStride = static_cast<size_t>(bps) * static_cast<size_t>(channels);

  float left[kChunkFrames];
  float right[kChunkFrames];
  int done = 0;
  while (done < frames) {
    const int n = std::min(kChunkFrames, frames - done);
    for (int i = 0; i < n; ++i) {
      const uint8_t* frame = bytes + static_cast<size_t>(done + i) * frameStride;
      if (channels == 1) {
        left[i] = right[i] = readSample(frame, encoding);
      } else if (channels == 2) {
        left[i] = readSample(frame, encoding);
        right[i] = readSample(frame + bps, encoding);
      } else {
        float l = 0.0f, r = 0.0f;
        for (int c = 0; c < usable; ++c) {
          if (fold.left[c] == 0.0f && fold.right[c] == 0.0f) continue;
          const float s = readSample(frame + static_cast<size_t>(c) * bps, encoding);
          l += s * fold.left[c];
          r += s * fold.right[c];
        }
        left[i] = l;
        right[i] = r;
      }
    }
    ring.push(left, right, static_cast<uint32_t>(n));
    done += n;
  }
}

}  // namespace noxira
