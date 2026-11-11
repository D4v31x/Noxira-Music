// Process-wide analysis engine: PCM sources in, NoxiraAudioFrames out.
//
// Threads
//   audio thread     push()/flush()/configure()   lock-free, never blocks
//   analysis thread  started by start(), joined by stop(); the only place
//                    where FFTs run and where memory is (re)allocated
//   Dart/UI thread   start/stop/updateConfig/acquireFrame
#ifndef NOXIRA_ENGINE_ANALYSIS_ENGINE_H_
#define NOXIRA_ENGINE_ANALYSIS_ENGINE_H_

#include <atomic>
#include <condition_variable>
#include <cstdint>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

#include "dsp/analysis_pipeline.h"
#include "dsp/stereo_ring.h"
#include "noxira_audio/noxira_audio.h"
#include "triple_buffer.h"

namespace noxira {

class AnalysisEngine {
 public:
  static AnalysisEngine& instance();

  AnalysisEngine();
  ~AnalysisEngine();
  AnalysisEngine(const AnalysisEngine&) = delete;
  AnalysisEngine& operator=(const AnalysisEngine&) = delete;

  // ---- lifecycle (idempotent) ----
  bool start(const NoxiraConfig& config);
  bool updateConfig(const NoxiraConfig& config);
  void stop();
  // Stops and frees the sample rings of unused sources.
  void shutdown();
  bool running() const { return running_.load(std::memory_order_acquire); }

  void setPlaybackState(int state);
  const NoxiraAudioFrame* acquireFrame();
  void setCallback(NoxiraFrameCallback callback);
  void getStats(NoxiraStats* out) const;

  // ---- PCM sources ----
  int acquireSource();
  void releaseSource(int id);
  void configureSource(int id, int sampleRate, int channels);
  void flushSource(int id);
  void endSource(int id);
  void updateClock(int id, int64_t queuedEndUs, int64_t audibleUs, float speed);
  int push(int id, const void* data, int frames, int encoding);

 private:
  struct Source {
    std::atomic<int> inUse{0};
    std::atomic<int> sampleRate{0};
    std::atomic<int> channels{0};
    std::atomic<uint32_t> epoch{0};
    std::atomic<uint64_t> streamStart{0};
    std::atomic<int> exactStart{0};  // flushed while analysis was running
    std::atomic<int> ended{0};
    std::atomic<uint64_t> order{0};  // newest stream has the highest value
    std::atomic<StereoRing*> ring{nullptr};
    std::atomic<uint32_t> clockVersion{0};
    std::atomic<uint32_t> clockEpoch{0};
    std::atomic<int64_t> clockFrame{0};
    std::atomic<int64_t> clockTimeNs{0};
  };

  // Analysis-thread view of one source.
  struct Cursor {
    uint32_t epochSeen = 0xFFFFFFFFu;
    bool valid = false;
    double position = 0.0;       // frames, same space as StereoRing::head()
    uint64_t streamStart = 0;
  };

  void ensureRings();
  void threadMain();
  void tick(double dt);
  void publishMeta(NoxiraAudioFrame* frame, int state, int sampleRate, int channels,
                   int64_t timestampUs);

  std::atomic<bool> running_{false};
  std::atomic<bool> stopRequested_{false};
  std::atomic<int> playbackState_{NOXIRA_STATE_PLAYING};
  std::atomic<NoxiraFrameCallback> callback_{nullptr};
  std::atomic<uint64_t> orderCounter_{0};
  std::atomic<bool> wake_{false};

  std::mutex lifecycleMutex_;  // serialises start/stop/shutdown/ensureRings
  std::mutex wakeMutex_;
  std::condition_variable wakeCv_;
  std::thread thread_;

  std::mutex configMutex_;
  NoxiraConfig pendingConfig_{};
  std::atomic<bool> configDirty_{false};

  Source sources_[NOXIRA_MAX_SOURCES];
  Cursor cursors_[NOXIRA_MAX_SOURCES];

  // Analysis-thread state.
  AnalysisPipeline pipeline_;
  NoxiraConfig activeConfig_{};
  std::vector<float> mixLeft_, mixRight_, tmpLeft_, tmpRight_;
  float pipelineRate_ = 0.0f;
  int discontinuities_ = 0;
  int lastPublishedState_ = -1;
  bool pendingDiscontinuity_ = false;
  int64_t sequence_ = 0;
  bool lastWasIdle_ = false;

  TripleBuffer<NoxiraAudioFrame> frames_;

  // Stats.
  std::atomic<int64_t> framesPublished_{0};
  std::atomic<int64_t> pushCalls_{0};
  std::atomic<int64_t> pushedFrames_{0};
  std::atomic<int64_t> ringOverruns_{0};
  std::atomic<uint64_t> pushNsTotal_{0};
  std::atomic<uint64_t> pushNsMax_{0};
  std::atomic<uint64_t> processNsTotal_{0};
  std::atomic<uint64_t> processNsMax_{0};
  std::atomic<int64_t> processedFrames_{0};
  std::atomic<int64_t> cpuNsTotal_{0};
  std::atomic<int64_t> wallNsTotal_{0};
};

}  // namespace noxira

#endif  // NOXIRA_ENGINE_ANALYSIS_ENGINE_H_
