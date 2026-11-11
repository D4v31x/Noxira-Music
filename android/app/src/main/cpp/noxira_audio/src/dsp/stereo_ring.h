// Single-producer / single-consumer ring of stereo float frames.
//
// The producer is the audio (playback) thread, the consumer the analysis
// thread. The producer never blocks or allocates. The consumer reads windows
// by absolute frame index; if the producer lapped it, the read is reported as
// invalid instead of returning torn data.
#ifndef NOXIRA_DSP_STEREO_RING_H_
#define NOXIRA_DSP_STEREO_RING_H_

#include <atomic>
#include <cstdint>
#include <cstring>
#include <memory>

namespace noxira {

class StereoRing {
 public:
  // capacityFrames must be a power of two.
  explicit StereoRing(uint32_t capacityFrames)
      : capacity_(capacityFrames),
        mask_(capacityFrames - 1),
        left_(new float[capacityFrames]()),
        right_(new float[capacityFrames]()) {}

  uint32_t capacity() const { return capacity_; }

  // Total frames ever written (monotonic, never reset).
  uint64_t head() const { return head_.load(std::memory_order_acquire); }

  // Producer only.
  void push(const float* left, const float* right, uint32_t frames) {
    uint64_t pos = head_.load(std::memory_order_relaxed);
    for (uint32_t i = 0; i < frames; ++i) {
      const uint32_t idx = static_cast<uint32_t>(pos + i) & mask_;
      left_[idx] = left[i];
      right_[idx] = right[i];
    }
    head_.store(pos + frames, std::memory_order_release);
  }

  // Consumer only. Copies [from, from + frames). Frames before `floor` (the
  // start of the current stream) are zero-filled. Returns false if the data
  // is no longer (or not yet) fully available in the ring.
  bool read(uint64_t from, uint32_t frames, uint64_t floor, float* left,
            float* right) const {
    const uint64_t headBefore = head_.load(std::memory_order_acquire);
    if (from + frames > headBefore) return false;
    if (headBefore > from && headBefore - from > capacity_) return false;
    for (uint32_t i = 0; i < frames; ++i) {
      const uint64_t pos = from + i;
      if (pos < floor) {
        left[i] = 0.0f;
        right[i] = 0.0f;
      } else {
        const uint32_t idx = static_cast<uint32_t>(pos) & mask_;
        left[i] = left_[idx];
        right[i] = right_[idx];
      }
    }
    // The producer may have lapped us while copying.
    const uint64_t headAfter = head_.load(std::memory_order_acquire);
    return headAfter - from <= capacity_;
  }

 private:
  const uint32_t capacity_;
  const uint32_t mask_;
  std::unique_ptr<float[]> left_;
  std::unique_ptr<float[]> right_;
  std::atomic<uint64_t> head_{0};
};

}  // namespace noxira

#endif  // NOXIRA_DSP_STEREO_RING_H_
