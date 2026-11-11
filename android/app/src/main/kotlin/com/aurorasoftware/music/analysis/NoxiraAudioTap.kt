package com.aurorasoftware.music.analysis

import androidx.media3.common.C
import androidx.media3.common.audio.AudioProcessor.AudioFormat
import androidx.media3.common.audio.BaseAudioProcessor
import androidx.media3.common.util.UnstableApi
import java.nio.ByteBuffer
import com.ryanheise.just_audio.AudioProcessorHook

/**
 * A pass-through ExoPlayer [androidx.media3.common.audio.AudioProcessor] that
 * lets the native analysis engine observe the PCM Noxira is actually playing.
 *
 * It sits at the end of the sink's processor chain, so it sees exactly what is
 * written to the AudioTrack (after speed changes and silence skipping), and it
 * never alters the audio. It does not touch the microphone or any audio
 * session, so it needs no permission and cannot distort playback.
 *
 * Audio-thread rules: [queueInput] only does one memcpy (required by
 * ExoPlayer's processor contract, so the codec may reuse its buffer) and one
 * non-blocking JNI call that returns immediately while analysis is off.
 * Allocations happen only in [onConfigure], when the stream format changes.
 *
 * Offload and passthrough playback (e.g. E-AC-3 sent as-is to an HDMI sink)
 * bypass audio processors in ExoPlayer, so nothing reaches the engine then.
 */
@UnstableApi
internal class NoxiraAudioTap : BaseAudioProcessor(), AudioProcessorHook.ClockListener {

    @Volatile private var sourceId = -1
    private var encoding = 0
    private var bytesPerFrame = 0

    override fun onConfigure(inputAudioFormat: AudioFormat): AudioFormat {
        val code = engineEncoding(inputAudioFormat.encoding)
        if (!NoxiraNative.available || code == 0 || inputAudioFormat.channelCount < 1) {
            // Not analysable (or no native library): stay out of the chain.
            releaseSource()
            return AudioFormat.NOT_SET
        }
        encoding = code
        bytesPerFrame = bytesPerSample(inputAudioFormat.encoding) * inputAudioFormat.channelCount
        if (sourceId < 0) sourceId = NoxiraNative.nativeAcquireSource()
        if (sourceId >= 0) {
            NoxiraNative.nativeConfigureSource(
                sourceId,
                inputAudioFormat.sampleRate,
                inputAudioFormat.channelCount,
            )
        }
        return inputAudioFormat
    }

    override fun queueInput(inputBuffer: ByteBuffer) {
        val size = inputBuffer.remaining()
        if (size == 0) return
        val output = replaceOutputBuffer(size)
        val id = sourceId
        if (id >= 0 && bytesPerFrame > 0) {
            NoxiraNative.nativePush(
                id,
                inputBuffer,
                inputBuffer.position(),
                size / bytesPerFrame,
                encoding,
            )
        }
        output.put(inputBuffer)
        output.flip()
    }

    override fun onQueueEndOfStream() {
        val id = sourceId
        if (id >= 0) NoxiraNative.nativeEndSource(id)
    }

    override fun onAudioClock(queuedEndUs: Long, audiblePositionUs: Long, speed: Float) {
        val id = sourceId
        if (id >= 0) {
            NoxiraNative.nativeUpdateClock(id, queuedEndUs, audiblePositionUs, speed)
        }
    }

    override fun onFlush() {
        val id = sourceId
        if (id >= 0) NoxiraNative.nativeFlushSource(id)
    }

    override fun onReset() {
        releaseSource()
        encoding = 0
        bytesPerFrame = 0
    }

    private fun releaseSource() {
        val id = sourceId
        sourceId = -1
        if (id >= 0 && NoxiraNative.available) NoxiraNative.nativeReleaseSource(id)
    }

    private fun engineEncoding(exoEncoding: Int): Int = when (exoEncoding) {
        C.ENCODING_PCM_16BIT -> NoxiraNative.PCM_S16
        C.ENCODING_PCM_8BIT -> NoxiraNative.PCM_U8
        C.ENCODING_PCM_24BIT -> NoxiraNative.PCM_S24
        C.ENCODING_PCM_32BIT -> NoxiraNative.PCM_S32
        C.ENCODING_PCM_FLOAT -> NoxiraNative.PCM_F32
        else -> 0
    }

    private fun bytesPerSample(exoEncoding: Int): Int = when (exoEncoding) {
        C.ENCODING_PCM_8BIT -> 1
        C.ENCODING_PCM_16BIT -> 2
        C.ENCODING_PCM_24BIT -> 3
        C.ENCODING_PCM_32BIT, C.ENCODING_PCM_FLOAT -> 4
        else -> 0
    }
}
