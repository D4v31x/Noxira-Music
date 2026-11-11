package com.aurorasoftware.music.analysis

import java.nio.ByteBuffer

/**
 * JNI entry points of the native audio analysis engine (libnoxira_audio.so).
 *
 * Only the playback tap uses this; Dart talks to the same library through FFI.
 * Both sides share one process-wide engine, so no handle is passed around.
 * Every call is lock-free and safe to make from the audio thread.
 */
object NoxiraNative {
    // PCM encodings understood by the engine (NoxiraPcmEncoding in noxira_audio.h).
    const val PCM_S16 = 1
    const val PCM_U8 = 2
    const val PCM_S24 = 3
    const val PCM_S32 = 4
    const val PCM_F32 = 5

    @Volatile
    var available: Boolean = false
        private set

    init {
        available = try {
            System.loadLibrary("noxira_audio")
            true
        } catch (_: UnsatisfiedLinkError) {
            false
        }
    }

    /** A free source slot id, or -1 when none is left. */
    @JvmStatic external fun nativeAcquireSource(): Int

    @JvmStatic external fun nativeReleaseSource(source: Int)

    /** Announces a new stream (sample rate / channel layout); implies a flush. */
    @JvmStatic external fun nativeConfigureSource(source: Int, sampleRate: Int, channels: Int)

    /** Seek, track change or other discontinuity: drops buffered history. */
    @JvmStatic external fun nativeFlushSource(source: Int)

    @JvmStatic external fun nativeEndSource(source: Int)
    @JvmStatic external fun nativeUpdateClock(
        source: Int, queuedEndUs: Long, audiblePositionUs: Long, speed: Float,
    )

    /**
     * Hands interleaved PCM to the engine without copying. [buffer] must be a
     * direct buffer; [byteOffset] is where the PCM starts. Returns the number
     * of frames consumed (0 while analysis is off), or -1 for a non-direct buffer.
     */
    @JvmStatic
    external fun nativePush(
        source: Int,
        buffer: ByteBuffer,
        byteOffset: Int,
        frames: Int,
        encoding: Int,
    ): Int

    @JvmStatic external fun nativeIsRunning(): Boolean
}
