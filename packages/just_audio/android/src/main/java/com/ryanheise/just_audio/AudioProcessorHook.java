package com.ryanheise.just_audio;

import android.content.Context;
import androidx.annotation.Nullable;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.audio.AudioProcessor;
import androidx.media3.exoplayer.audio.AudioSink;
import androidx.media3.exoplayer.audio.DefaultAudioSink;
import androidx.media3.exoplayer.audio.ForwardingAudioSink;
import java.nio.ByteBuffer;

/**
 * LOCAL PATCH (Noxira): lets the host app append a pass-through
 * {@link AudioProcessor} to the end of ExoPlayer's audio processor chain, so
 * decoded PCM can be observed without a second playback pipeline.
 *
 * Upstream just_audio builds its renderers with a plain DefaultRenderersFactory
 * and offers no way to add audio processors. The only change to upstream code
 * is in {@code AudioPlayer.ensurePlayerInitialized()}, which routes
 * {@code buildAudioSink} through {@link #buildAudioSink}. With no provider
 * registered the behaviour is identical to upstream.
 */
public final class AudioProcessorHook {

    /** Creates the processor appended to the chain of one player's audio sink. */
    public interface Provider {
        /** Called once per ExoPlayer audio sink; the result must not be shared. */
        AudioProcessor createTailProcessor();
    }

    /** Optional clock metadata for an observing processor; never changes playback. */
    public interface ClockListener {
        void onAudioClock(long queuedEndUs, long audiblePositionUs, float speed);
    }

    @Nullable private static volatile Provider provider;

    private AudioProcessorHook() {}

    /** Registers (or clears, with null) the provider. Applies to players created afterwards. */
    public static void setProvider(@Nullable Provider newProvider) {
        provider = newProvider;
    }

    /**
     * Builds the audio sink for a new player, or returns null when no provider
     * is registered so the caller keeps ExoPlayer's default sink.
     */
    @Nullable
    static AudioSink buildAudioSink(
            Context context, boolean enableFloatOutput, boolean enableAudioTrackPlaybackParams) {
        Provider current = provider;
        if (current == null) return null;
        AudioProcessor tail = current.createTailProcessor();
        if (tail == null) return null;
        AudioSink sink = new DefaultAudioSink.Builder(context)
                .setEnableFloatOutput(enableFloatOutput)
                .setEnableAudioTrackPlaybackParams(enableAudioTrackPlaybackParams)
                .setAudioProcessorChain(new TailAppendingChain(tail))
                .build();
        return tail instanceof ClockListener
                ? new ClockedSink(sink, (ClockListener) tail)
                : sink;
    }

    private static final class ClockedSink extends ForwardingAudioSink {
        private final ClockListener listener;
        private int sampleRate;
        private int bytesPerFrame;
        private ByteBuffer currentBuffer;
        private long presentationUs = Long.MIN_VALUE;
        private int initialPosition;
        private long queuedEndUs = Long.MIN_VALUE;

        ClockedSink(AudioSink sink, ClockListener listener) {
            super(sink);
            this.listener = listener;
        }

        @Override
        public void configure(Format format, int bufferSize, @Nullable int[] channels)
                throws ConfigurationException {
            super.configure(format, bufferSize, channels);
            sampleRate = format.sampleRate;
            int bytes;
            switch (format.pcmEncoding) {
                case C.ENCODING_PCM_8BIT: bytes = 1; break;
                case C.ENCODING_PCM_16BIT: bytes = 2; break;
                case C.ENCODING_PCM_24BIT: bytes = 3; break;
                case C.ENCODING_PCM_32BIT:
                case C.ENCODING_PCM_FLOAT: bytes = 4; break;
                default: bytes = 0;
            }
            bytesPerFrame = bytes * Math.max(0, format.channelCount);
        }

        @Override
        public boolean handleBuffer(ByteBuffer buffer, long timeUs, int accessUnits)
                throws InitializationException, WriteException {
            if (buffer != currentBuffer || timeUs != presentationUs) {
                currentBuffer = buffer;
                presentationUs = timeUs;
                initialPosition = buffer.position();
            }
            boolean consumed = super.handleBuffer(buffer, timeUs, accessUnits);
            if (bytesPerFrame > 0 && sampleRate > 0) {
                long frames = (buffer.position() - initialPosition) / bytesPerFrame;
                queuedEndUs = timeUs + frames * 1_000_000L / sampleRate;
            }
            return consumed;
        }

        @Override
        public long getCurrentPositionUs(boolean ended) {
            long positionUs = super.getCurrentPositionUs(ended);
            if (positionUs != Long.MIN_VALUE && queuedEndUs != Long.MIN_VALUE) {
                listener.onAudioClock(queuedEndUs, positionUs, getPlaybackParameters().speed);
            }
            return positionUs;
        }

        @Override
        public void flush() {
            currentBuffer = null;
            presentationUs = queuedEndUs = Long.MIN_VALUE;
            super.flush();
        }

        @Override
        public void reset() {
            currentBuffer = null;
            presentationUs = queuedEndUs = Long.MIN_VALUE;
            super.reset();
        }
    }

    /**
     * ExoPlayer's default chain (silence skipping, speed) followed by the tail
     * processor, so the tail observes exactly what is written to the AudioTrack.
     */
    private static final class TailAppendingChain implements DefaultAudioSink.AudioProcessorChain {
        private final DefaultAudioSink.DefaultAudioProcessorChain delegate =
                new DefaultAudioSink.DefaultAudioProcessorChain();
        private final AudioProcessor[] processors;

        TailAppendingChain(AudioProcessor tail) {
            AudioProcessor[] base = delegate.getAudioProcessors();
            processors = new AudioProcessor[base.length + 1];
            System.arraycopy(base, 0, processors, 0, base.length);
            processors[base.length] = tail;
        }

        @Override
        public AudioProcessor[] getAudioProcessors() {
            return processors;
        }

        @Override
        public PlaybackParameters applyPlaybackParameters(PlaybackParameters playbackParameters) {
            return delegate.applyPlaybackParameters(playbackParameters);
        }

        @Override
        public boolean applySkipSilenceEnabled(boolean skipSilenceEnabled) {
            return delegate.applySkipSilenceEnabled(skipSilenceEnabled);
        }

        @Override
        public long getMediaDuration(long playoutDuration) {
            return delegate.getMediaDuration(playoutDuration);
        }

        @Override
        public long getSkippedOutputFrameCount() {
            return delegate.getSkippedOutputFrameCount();
        }
    }
}
