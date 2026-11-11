// PCM -> stereo float conversion with a channel fold-down.
#ifndef NOXIRA_DSP_PCM_CONVERT_H_
#define NOXIRA_DSP_PCM_CONVERT_H_

#include <cstdint>

#include "noxira_audio/noxira_audio.h"
#include "stereo_ring.h"

namespace noxira {

// Number of bytes of one interleaved frame, 0 for an unknown encoding.
int bytesPerSample(int encoding);

// Converts interleaved PCM to stereo floats (-1..1) and pushes them into
// `ring` in small stack-sized chunks: no allocation, no blocking.
//
// Mono is duplicated. Stereo is passed through. For more channels the
// Android channel order (FL FR FC LFE then alternating left/right surround
// and height channels) is folded down: centre at -3 dB, surrounds and
// heights at -6 dB, LFE dropped, then scaled by 1/sqrt(sum of squared gains)
// so uncorrelated surround content keeps its power. Fully correlated
// full-scale content can therefore exceed 1.0, which is harmless for analysis.
void pushPcm(StereoRing& ring, const void* data, int frames, int channels,
             int encoding);

}  // namespace noxira

#endif  // NOXIRA_DSP_PCM_CONVERT_H_
