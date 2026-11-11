// Lock-free single-writer / single-reader triple buffer.
//
// The writer always has a private buffer to fill; publish() hands it over and
// returns the previously unused one. The reader's buffer is never touched by
// the writer, so acquire() returns tear-free data with no copying and no locks.
#ifndef NOXIRA_ENGINE_TRIPLE_BUFFER_H_
#define NOXIRA_ENGINE_TRIPLE_BUFFER_H_

#include <atomic>
#include <cstdint>

namespace noxira {

template <typename T>
class TripleBuffer {
 public:
  // Writer only: the buffer that may be filled right now.
  T* back() { return &slots_[backIndex_]; }

  // Writer only: makes the back buffer visible to the reader.
  void publish() {
    const uint32_t previous = middle_.exchange(backIndex_ | kDirty, std::memory_order_acq_rel);
    backIndex_ = previous & kIndexMask;
  }

  // Reader only: the newest unread buffer, or nullptr if nothing new was
  // published. The pointer stays valid until the next acquire().
  const T* acquire() {
    if (!(middle_.load(std::memory_order_acquire) & kDirty)) return nullptr;
    const uint32_t previous = middle_.exchange(frontIndex_, std::memory_order_acq_rel);
    frontIndex_ = previous & kIndexMask;
    return &slots_[frontIndex_];
  }

  // Initialisation helper (not thread-safe).
  T* slot(int i) { return &slots_[i]; }

 private:
  static constexpr uint32_t kDirty = 4;
  static constexpr uint32_t kIndexMask = 3;
  T slots_[3];
  uint32_t backIndex_ = 0;
  uint32_t frontIndex_ = 2;
  std::atomic<uint32_t> middle_{1};
};

}  // namespace noxira

#endif  // NOXIRA_ENGINE_TRIPLE_BUFFER_H_
