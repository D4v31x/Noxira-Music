// JNI bridge used by the Kotlin playback tap (NoxiraNative). Only thin
// forwarding to the C ABI; the hot call, nativePush, takes a direct buffer so
// no data is copied across the JNI boundary.
#include <jni.h>

#include <cstdint>

#include "noxira_audio/noxira_audio.h"

#define NOXIRA_JNI(name) Java_com_aurorasoftware_music_analysis_NoxiraNative_##name

extern "C" {

JNIEXPORT jint JNICALL NOXIRA_JNI(nativeAcquireSource)(JNIEnv*, jclass) {
  return noxira_engine_acquire_source();
}

JNIEXPORT void JNICALL NOXIRA_JNI(nativeReleaseSource)(JNIEnv*, jclass, jint source) {
  noxira_engine_release_source(source);
}

JNIEXPORT void JNICALL NOXIRA_JNI(nativeConfigureSource)(JNIEnv*, jclass, jint source,
                                                         jint sampleRate, jint channels) {
  noxira_engine_configure_source(source, sampleRate, channels);
}

JNIEXPORT void JNICALL NOXIRA_JNI(nativeFlushSource)(JNIEnv*, jclass, jint source) {
  noxira_engine_flush_source(source);
}

JNIEXPORT void JNICALL NOXIRA_JNI(nativeEndSource)(JNIEnv*, jclass, jint source) {
  noxira_engine_end_source(source);
}

// `buffer` must be a direct ByteBuffer; `byteOffset` is where the PCM starts.
JNIEXPORT jint JNICALL NOXIRA_JNI(nativePush)(JNIEnv* env, jclass, jint source, jobject buffer,
                                              jint byteOffset, jint frames, jint encoding) {
  void* base = env->GetDirectBufferAddress(buffer);
  if (base == nullptr) return -1;
  return noxira_engine_push_pcm(source, static_cast<const uint8_t*>(base) + byteOffset, frames,
                                encoding);
}

JNIEXPORT jboolean JNICALL NOXIRA_JNI(nativeIsRunning)(JNIEnv*, jclass) {
  return noxira_engine_is_running() ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT void JNICALL NOXIRA_JNI(nativeUpdateClock)(
    JNIEnv*, jclass, jint source, jlong queuedEndUs, jlong audibleUs, jfloat speed) {
  noxira_engine_update_clock(source, queuedEndUs, audibleUs, speed);
}

}  // extern "C"
