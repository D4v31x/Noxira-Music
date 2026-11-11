// C ABI of the engine: consumed by Dart FFI and by the JNI bridge.
#include <cstring>

#include "dsp/analysis_pipeline.h"
#include "engine/analysis_engine.h"
#include "noxira_audio/noxira_audio.h"

using noxira::AnalysisEngine;

extern "C" {

int32_t noxira_abi_version(void) { return NOXIRA_ABI_VERSION; }

int32_t noxira_frame_size(void) { return static_cast<int32_t>(sizeof(NoxiraAudioFrame)); }

int32_t noxira_config_size(void) { return static_cast<int32_t>(sizeof(NoxiraConfig)); }

void noxira_config_default(NoxiraConfig* out) {
  if (out != nullptr) noxira::fillDefaultConfig(out);
}

int32_t noxira_engine_start(const NoxiraConfig* config) {
  NoxiraConfig effective;
  noxira::fillDefaultConfig(&effective);
  if (config != nullptr && config->struct_size == static_cast<int32_t>(sizeof(NoxiraConfig))) {
    effective = *config;
  }
  return AnalysisEngine::instance().start(effective) ? 1 : 0;
}

int32_t noxira_engine_update_config(const NoxiraConfig* config) {
  if (config == nullptr || config->struct_size != static_cast<int32_t>(sizeof(NoxiraConfig))) {
    return 0;
  }
  return AnalysisEngine::instance().updateConfig(*config) ? 1 : 0;
}

void noxira_engine_stop(void) { AnalysisEngine::instance().stop(); }

void noxira_engine_shutdown(void) { AnalysisEngine::instance().shutdown(); }

int32_t noxira_engine_is_running(void) { return AnalysisEngine::instance().running() ? 1 : 0; }

void noxira_engine_set_playback_state(int32_t state) {
  AnalysisEngine::instance().setPlaybackState(state);
}

const NoxiraAudioFrame* noxira_engine_acquire_frame(void) {
  return AnalysisEngine::instance().acquireFrame();
}

void noxira_engine_set_frame_callback(NoxiraFrameCallback callback) {
  AnalysisEngine::instance().setCallback(callback);
}

void noxira_engine_get_stats(NoxiraStats* out) {
  if (out != nullptr) AnalysisEngine::instance().getStats(out);
}

int32_t noxira_engine_acquire_source(void) { return AnalysisEngine::instance().acquireSource(); }

void noxira_engine_release_source(int32_t source) {
  AnalysisEngine::instance().releaseSource(source);
}

void noxira_engine_configure_source(int32_t source, int32_t sample_rate, int32_t channels) {
  AnalysisEngine::instance().configureSource(source, sample_rate, channels);
}

void noxira_engine_flush_source(int32_t source) { AnalysisEngine::instance().flushSource(source); }

void noxira_engine_end_source(int32_t source) { AnalysisEngine::instance().endSource(source); }

void noxira_engine_update_clock(int32_t source, int64_t queued_end_us, int64_t audible_us,
                                float speed) {
  AnalysisEngine::instance().updateClock(source, queued_end_us, audible_us, speed);
}

int32_t noxira_engine_push_pcm(int32_t source, const void* data, int32_t frame_count,
                               int32_t encoding) {
  return AnalysisEngine::instance().push(source, data, frame_count, encoding);
}

}  // extern "C"
