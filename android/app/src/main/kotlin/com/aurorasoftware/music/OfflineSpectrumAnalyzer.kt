package com.aurorasoftware.music

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.util.Log
import java.io.ByteArrayOutputStream
import java.nio.ByteOrder
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Legacy Dolby workaround: decode a short file slice without attaching an
 * audio effect to the playback session.
 */
class OfflineSpectrumAnalyzer(private val context: Context) {
    class Result(
        val sampleRate: Int,
        val bins: Int,
        val durationUs: Long,
        val data: ByteArray,
    )

    companion object {
        const val FRAME_RATE = 30
        const val FFT_SIZE = 1024
        const val BINS = FFT_SIZE / 2
        private const val TIMEOUT_US = 10_000L
        private const val SEEK_MARGIN_SAMPLES = 4096L
        private val cosTable = FloatArray(FFT_SIZE / 2) {
            cos(2.0 * PI * it / FFT_SIZE).toFloat()
        }
        private val sinTable = FloatArray(FFT_SIZE / 2) {
            sin(2.0 * PI * it / FFT_SIZE).toFloat()
        }
    }

    fun analyze(
        path: String,
        uri: Uri?,
        startFrame: Int,
        frameCount: Int,
        isCancelled: () -> Boolean,
    ): Result? {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        try {
            if (uri != null) extractor.setDataSource(context, uri, null)
            else extractor.setDataSource(path)

            val track = (0 until extractor.trackCount).firstOrNull {
                extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)
                    ?.startsWith("audio/") == true
            } ?: throw IllegalArgumentException("File contains no audio track")
            extractor.selectTrack(track)
            val format = extractor.getTrackFormat(track)
            val mime = format.getString(MediaFormat.KEY_MIME)
                ?: throw IllegalArgumentException("Audio track has no MIME type")
            val durationUs = if (format.containsKey(MediaFormat.KEY_DURATION)) {
                format.getLong(MediaFormat.KEY_DURATION)
            } else {
                0L
            }
            var sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var floatPcm = false
            fun frameEnd(frame: Int): Long = (frame + 1L) * sampleRate / FRAME_RATE

            val seekSample = maxOf(
                0L,
                frameEnd(startFrame) - FFT_SIZE - SEEK_MARGIN_SAMPLES,
            )
            if (seekSample > 0) {
                extractor.seekTo(
                    seekSample * 1_000_000L / sampleRate,
                    MediaExtractor.SEEK_TO_PREVIOUS_SYNC,
                )
            }
            format.setInteger("max-output-channel-count", 2)
            codec = MediaCodec.createDecoderByType(mime)
            codec.configure(format, null, null, 0)
            codec.start()

            val out = ByteArrayOutputStream()
            val ring = FloatArray(FFT_SIZE)
            var ringPos = 0
            var nextFrame = startFrame
            val lastFrame = startFrame + frameCount
            var samplePos = -1L
            val re = FloatArray(FFT_SIZE)
            val im = FloatArray(FFT_SIZE)
            val frameBytes = ByteArray(BINS)
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false

            while (!outputDone && nextFrame < lastFrame) {
                if (isCancelled()) return null
                if (!inputDone) {
                    val inIndex = codec.dequeueInputBuffer(TIMEOUT_US)
                    if (inIndex >= 0) {
                        val buf = codec.getInputBuffer(inIndex)!!
                        val size = extractor.readSampleData(buf, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(
                                inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                            )
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(inIndex, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val outIndex = codec.dequeueOutputBuffer(info, TIMEOUT_US)
                when {
                    outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val outputFormat = codec.outputFormat
                        sampleRate = outputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                        channels = outputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                        floatPcm = outputFormat.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                            outputFormat.getInteger(MediaFormat.KEY_PCM_ENCODING) ==
                            android.media.AudioFormat.ENCODING_PCM_FLOAT
                    }
                    outIndex >= 0 -> {
                        val buf = codec.getOutputBuffer(outIndex)!!
                        buf.position(info.offset)
                        buf.limit(info.offset + info.size)
                        val pcm = buf.order(ByteOrder.nativeOrder())
                        val bytesPerSample = if (floatPcm) 4 else 2
                        val total = info.size / (bytesPerSample * channels)
                        if (samplePos < 0 && total > 0) {
                            samplePos = info.presentationTimeUs * sampleRate / 1_000_000L
                        }
                        var n = 0
                        while (n < total && nextFrame < lastFrame) {
                            var sum = 0f
                            for (c in 0 until channels) {
                                sum += if (floatPcm) pcm.getFloat() else pcm.getShort() / 32768f
                            }
                            ring[ringPos] = sum / sqrt(channels.toFloat())
                            ringPos = (ringPos + 1) % FFT_SIZE
                            samplePos++
                            n++
                            if (samplePos >= frameEnd(nextFrame)) {
                                for (i in 0 until FFT_SIZE) {
                                    re[i] = ring[(ringPos + i) % FFT_SIZE]
                                    im[i] = 0f
                                }
                                fft(re, im)
                                for (k in 0 until BINS) {
                                    val mag = sqrt(re[k] * re[k] + im[k] * im[k]) /
                                        (FFT_SIZE / 2f)
                                    frameBytes[k] = min(255f, mag * 384f).toInt().toByte()
                                }
                                out.write(frameBytes)
                                nextFrame++
                            }
                        }
                        codec.releaseOutputBuffer(outIndex, false)
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                            outputDone = true
                        }
                    }
                }
            }
            return Result(sampleRate, BINS, durationUs, out.toByteArray())
        } finally {
            try {
                try {
                    codec?.stop()
                } catch (error: IllegalStateException) {
                    Log.w("AuroraVisualizer", "Decoder was not running during cleanup", error)
                } finally {
                    codec?.release()
                }
            } finally {
                extractor.release()
            }
        }
    }

    private fun fft(re: FloatArray, im: FloatArray) {
        val n = FFT_SIZE
        var j = 0
        for (i in 1 until n) {
            var bit = n shr 1
            while (j and bit != 0) {
                j = j xor bit
                bit = bit shr 1
            }
            j = j xor bit
            if (i < j) {
                val real = re[i]
                re[i] = re[j]
                re[j] = real
                val imaginary = im[i]
                im[i] = im[j]
                im[j] = imaginary
            }
        }
        var length = 2
        while (length <= n) {
            val half = length shr 1
            val step = n / length
            var i = 0
            while (i < n) {
                var k = 0
                for (m in 0 until half) {
                    val wr = cosTable[k]
                    val wi = -sinTable[k]
                    val a = i + m
                    val b = a + half
                    val xr = re[b] * wr - im[b] * wi
                    val xi = re[b] * wi + im[b] * wr
                    re[b] = re[a] - xr
                    im[b] = im[a] - xi
                    re[a] += xr
                    im[a] += xi
                    k += step
                }
                i += length
            }
            length = length shl 1
        }
    }
}
