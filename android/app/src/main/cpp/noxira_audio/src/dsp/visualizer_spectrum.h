#ifndef NOXIRA_VISUALIZER_SPECTRUM_H_
#define NOXIRA_VISUALIZER_SPECTRUM_H_

#include "noxira_audio/noxira_audio.h"

namespace noxira {

// A common capture gain keeps the display's level range, without quantizing
// bins or normalizing each frequency independently.
void visualizerSpectrum(const float* amplitude, const float* left, const float* right,
                        int fftSize, float* magnitude);

}  // namespace noxira
#endif
