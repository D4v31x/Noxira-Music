package com.aurorasoftware.music

import android.app.Application
import androidx.media3.common.util.UnstableApi
import com.aurorasoftware.music.analysis.NoxiraAudioTap
import com.ryanheise.just_audio.AudioProcessorHook

class NoxiraApplication : Application() {
    @OptIn(UnstableApi::class)
    override fun onCreate() {
        super.onCreate()
        // Must happen before the first just_audio player is created, which can
        // also be the audio service starting without any activity.
        AudioProcessorHook.setProvider { NoxiraAudioTap() }
    }
}
