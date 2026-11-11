# KissFFT (vendored)

Upstream: https://github.com/mborgerding/kissfft, release 131.1.0 (BSD-3-Clause,
see `COPYING`). Only the files needed for the single-precision real FFT are
included: `kiss_fft.c/.h`, `kiss_fftr.c/.h`, `_kiss_fft_guts.h`, `kiss_fft_log.h`.
They are unmodified. Used through `src/dsp/real_fft.cpp`.
