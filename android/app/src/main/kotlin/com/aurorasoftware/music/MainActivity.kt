package com.aurorasoftware.music

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.ContentValues
import android.content.Intent
import android.media.AudioManager
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity
import android.media.audiofx.Equalizer
import android.media.audiofx.Visualizer
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import java.util.concurrent.atomic.AtomicReference
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : AudioServiceActivity() {

    companion object {
        private const val EFFECTS_CHANNEL = "aurora/effects"
        private const val SAF_CHANNEL = "aurora/saf_write"
        private const val MEDIA_ACTIONS_CHANNEL = "aurora/media_actions"
        private const val DEVICE_PROBE_CHANNEL = "aurora/device_probe"
        private const val VISUALIZER_CHANNEL = "aurora/visualizer"
        private const val FFT_POLL_INTERVAL_MS = 16L
        private const val REQUEST_WRITE_PERMISSION = 42
        private const val REQUEST_DELETE_PERMISSION = 43
    }

    // Holds state for a pending write that is waiting for the user to approve
    // the MediaStore.createWriteRequest system dialog.
    private data class PendingWrite(
        val tempPath: String,
        val mediaUri: Uri,
        val result: MethodChannel.Result,
    )
    private var pendingWrite: PendingWrite? = null

    // Holds state for a pending delete awaiting MediaStore.createDeleteRequest approval.
    private var pendingDeleteResult: MethodChannel.Result? = null

    private var audioOutputChannel: AudioOutputChannel? = null
    private var activeVisualizer: Visualizer? = null
    private val visualizerHandler = Handler(Looper.getMainLooper())
    private var vizThread: HandlerThread? = null
    private var vizPoller: Handler? = null
    @Volatile private var isStreamingFft = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge display for Android 15+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }

    /**
     * Reads real hardware capabilities. Build.MODEL / BRAND are easily spoofed
     * by custom ROMs, so RAM, core count and CPU frequency are what we trust.
     */
    private fun probeHardware(): Map<String, Any?> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)

        var maxFreqKHz = 0L
        try {
            File("/sys/devices/system/cpu").listFiles()
                ?.filter { it.name.matches(Regex("cpu\\d+")) }
                ?.forEach {
                    val f = File(it, "cpufreq/cpuinfo_max_freq")
                    if (f.canRead()) {
                        val v = f.readText().trim().toLongOrNull() ?: 0L
                        if (v > maxFreqKHz) maxFreqKHz = v
                    }
                }
        } catch (_: Exception) {
        }

        val socModel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) Build.SOC_MODEL else ""
        val refreshRate = try {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.refreshRate.toDouble()
        } catch (_: Exception) {
            60.0
        }

        return mapOf(
            "totalRamMb" to memInfo.totalMem / (1024 * 1024),
            "isLowRamDevice" to am.isLowRamDevice,
            "memoryClassMb" to am.memoryClass,
            "cpuCores" to Runtime.getRuntime().availableProcessors(),
            "maxCpuFreqMhz" to if (maxFreqKHz > 0) maxFreqKHz / 1000 else null,
            "hardware" to Build.HARDWARE,
            "board" to Build.BOARD,
            "socModel" to socModel,
            "sdk" to Build.VERSION.SDK_INT,
            "hasVulkan" to packageManager.hasSystemFeature(PackageManager.FEATURE_VULKAN_HARDWARE_LEVEL),
            "refreshRate" to refreshRate,
        )
    }

    /**
     * Whether an [Equalizer] can be created on a fresh audio session. Devices
     * that refuse (or have run out of effect instances) make the player fail
     * with "Cannot initialize effect engine".
     */
    private fun canCreateEqualizer(): Boolean {
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val equalizer = Equalizer(0, audioManager.generateAudioSessionId())
            equalizer.release()
            true
        } catch (_: Throwable) {
            false
        }
    }

    override fun onDestroy() {
        stopFftPolling()
        audioOutputChannel?.dispose()
        audioOutputChannel = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_PROBE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "probe" -> result.success(probeHardware())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EFFECTS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canCreateEqualizer" -> result.success(canCreateEqualizer())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SAF_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "writeFileViaMediaStore" -> {
                        val tempPath = call.argument<String>("tempPath")
                        val originalPath = call.argument<String>("originalPath")
                        if (tempPath == null || originalPath == null) {
                            result.error("INVALID_ARGS", "tempPath and originalPath are required", null)
                            return@setMethodCallHandler
                        }
                        handleWriteRequest(tempPath, originalPath, result)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_ACTIONS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setAsRingtone" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARGS", "path is required", null)
                            return@setMethodCallHandler
                        }
                        handleSetRingtone(path, result)
                    }
                    "deleteSong" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARGS", "path is required", null)
                            return@setMethodCallHandler
                        }
                        handleDeleteSong(path, result)
                    }
                    "isDolbyAudio" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARGS", "path is required", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val isDolby = isDolbyAudio(path)
                                runOnUiThread { result.success(isDolby) }
                            } catch (error: Exception) {
                                Log.e("AuroraVisualizer", "Audio format probe failed", error)
                                runOnUiThread {
                                    result.error("PROBE_FAILED", error.message, null)
                                }
                            }
                        }.start()
                    }
                    "analyzeSpectrum" -> {
                        val path = call.argument<String>("path")
                        val startFrame = call.argument<Int>("startFrame")
                        val frameCount = call.argument<Int>("frameCount")
                        if (path == null || startFrame == null || startFrame < 0 ||
                            frameCount == null || frameCount !in 1..300
                        ) {
                            result.error(
                                "INVALID_ARGS",
                                "path, nonnegative startFrame and frameCount (1..300) are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val analysis = OfflineSpectrumAnalyzer(applicationContext)
                                    .analyze(
                                        path, getMediaUriForPath(path), startFrame, frameCount,
                                    ) { false }
                                runOnUiThread {
                                    result.success(
                                        analysis?.let {
                                            mapOf(
                                                "sampleRate" to it.sampleRate,
                                                "frameRate" to OfflineSpectrumAnalyzer.FRAME_RATE,
                                                "bins" to it.bins,
                                                "durationUs" to it.durationUs,
                                                "data" to it.data,
                                            )
                                        }
                                    )
                                }
                            } catch (error: Exception) {
                                Log.e("AuroraVisualizer", "Dolby spectrum decode failed", error)
                                runOnUiThread {
                                    result.error("ANALYSIS_FAILED", error.message, null)
                                }
                            }
                        }.start()
                    }
                    "openSystemEqualizer" -> {
                        try {
                            val intent = Intent("android.media.audiofx.AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL").apply {
                                putExtra("android.media.audiofx.AudioEffect.EXTRA_CONTENT_TYPE", 0)
                                val sessionId = call.argument<Int>("audioSessionId")
                                if (sessionId != null && sessionId != 0) {
                                    putExtra("android.media.audiofx.AudioEffect.EXTRA_AUDIO_SESSION", sessionId)
                                }
                            }
                            if (intent.resolveActivity(packageManager) != null) {
                                startActivity(intent)
                                result.success(true)
                            } else {
                                startActivity(Intent(Settings.ACTION_SOUND_SETTINGS))
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.error("FAILED", e.message ?: "Could not open system equalizer", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        audioOutputChannel?.dispose()
        audioOutputChannel = AudioOutputChannel(this, flutterEngine)
        setupVisualizerChannel(flutterEngine)
    }

    private fun setupVisualizerChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VISUALIZER_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    stopFftPolling()
                    val sessionId = when (arguments) {
                        is Int -> arguments
                        is Long -> arguments.toInt()
                        else -> 0
                    }
                    try {
                        val capSize = Visualizer.getCaptureSizeRange()[1]
                        val viz = Visualizer(sessionId)
                        activeVisualizer = viz
                        viz.captureSize = capSize
                        viz.enabled = true
                        isStreamingFft = true
                        val rate = viz.samplingRate
                        events?.success(
                            byteArrayOf(
                                3,
                                (rate shr 24).toByte(), (rate shr 16).toByte(),
                                (rate shr 8).toByte(), rate.toByte(),
                            )
                        )
                        startFftPolling(viz, capSize, events)
                    } catch (error: Exception) {
                        stopFftPolling()
                        events?.error("VISUALIZER_ERROR", error.message, null)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    stopFftPolling()
                }
            })
    }

    private fun startFftPolling(
        viz: Visualizer,
        captureSize: Int,
        events: EventChannel.EventSink?,
    ) {
        val thread = HandlerThread("AuroraVisualizer").also { it.start() }
        val poller = Handler(thread.looper)
        vizThread = thread
        vizPoller = poller
        val scratch = ByteArray(captureSize)
        val latest = AtomicReference<ByteArray?>(null)
        val task = object : Runnable {
            override fun run() {
                if (!isStreamingFft) return
                val startedAt = SystemClock.uptimeMillis()
                try {
                    if (viz.getFft(scratch) == Visualizer.SUCCESS) {
                        val frame = ByteArray(captureSize + 1)
                        frame[0] = 1
                        scratch.copyInto(frame, destinationOffset = 1)
                        if (latest.getAndSet(frame) == null) {
                            visualizerHandler.post {
                                val pending = latest.getAndSet(null)
                                if (isStreamingFft && pending != null) events?.success(pending)
                            }
                        }
                    }
                } catch (error: IllegalStateException) {
                    if (isStreamingFft) {
                        visualizerHandler.post {
                            events?.error("VISUALIZER_ERROR", error.message, null)
                        }
                    }
                    return
                }
                val elapsed = SystemClock.uptimeMillis() - startedAt
                poller.postDelayed(this, maxOf(1L, FFT_POLL_INTERVAL_MS - elapsed))
            }
        }
        poller.post(task)
    }

    private fun stopFftPolling() {
        isStreamingFft = false
        vizPoller?.removeCallbacksAndMessages(null)
        vizThread?.quitSafely()
        vizThread = null
        vizPoller = null
        visualizerHandler.removeCallbacksAndMessages(null)
        activeVisualizer?.release()
        activeVisualizer = null
    }

    private fun isDolbyAudio(path: String): Boolean {
        val extractor = MediaExtractor()
        return try {
            val uri = getMediaUriForPath(path)
            if (uri != null) extractor.setDataSource(this, uri, null)
            else extractor.setDataSource(path)
            (0 until extractor.trackCount).any { index ->
                val mime = extractor.getTrackFormat(index).getString(MediaFormat.KEY_MIME)
                mime != null && (mime == "audio/ac3" || mime.startsWith("audio/eac3"))
            }
        } finally {
            extractor.release()
        }
    }

    /**
     * Entry point for a write request.
     *
     * On API 30+ (Android 11+): resolve the MediaStore URI, then launch
     * [MediaStore.createWriteRequest] so the system shows the "Allow edit?"
     * dialog. The actual write happens in [onActivityResult] after approval.
     *
     * On API 29 (Android 10): attempt a direct write; if it throws a
     * SecurityException, fall back to createWriteRequest.
     */
    private fun handleWriteRequest(
        tempPath: String,
        originalPath: String,
        result: MethodChannel.Result,
    ) {
        try {
            val tempFile = File(tempPath)
            if (!tempFile.exists()) {
                result.error("INVALID_ARGS", "Temp file not found: $tempPath", null)
                return
            }

            val mediaUri = getMediaUriForPath(originalPath)
            if (mediaUri == null) {
                result.error(
                    "WRITE_FAILED",
                    "Could not resolve MediaStore URI for: $originalPath",
                    null
                )
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // API 30+ – always use createWriteRequest
                launchWriteRequest(tempPath, mediaUri, result)
            } else {
                // API 29 – try direct write; fall back on SecurityException
                try {
                    doWrite(tempPath, mediaUri)
                    result.success(null)
                } catch (se: SecurityException) {
                    launchWriteRequest(tempPath, mediaUri, result)
                }
            }
        } catch (e: Exception) {
            result.error("WRITE_FAILED", e.message, null)
        }
    }

    /**
     * Shows the system "Allow Noxira Music to modify this file?" dialog via
     * [MediaStore.createWriteRequest].
     */
    @Suppress("DEPRECATION")
    private fun launchWriteRequest(
        tempPath: String,
        mediaUri: Uri,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.error("WRITE_FAILED", "createWriteRequest requires API 30+", null)
            return
        }
        // Set pendingWrite only once the intent sender has actually launched —
        // otherwise a failure here would leave a stale pendingWrite pointing at
        // an already-replied result, risking a double reply later.
        try {
            val intentSender = MediaStore.createWriteRequest(contentResolver, listOf(mediaUri))
            pendingWrite = PendingWrite(tempPath, mediaUri, result)
            startIntentSenderForResult(intentSender.intentSender, REQUEST_WRITE_PERMISSION, null, 0, 0, 0)
        } catch (e: Exception) {
            pendingWrite = null
            result.error("WRITE_FAILED", e.message, null)
        }
    }

    @Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQUEST_WRITE_PERMISSION -> {
                val pw = pendingWrite
                pendingWrite = null
                if (pw == null) return

                if (resultCode == Activity.RESULT_OK) {
                    try {
                        doWrite(pw.tempPath, pw.mediaUri)
                        pw.result.success(null)
                    } catch (e: Exception) {
                        pw.result.error("WRITE_FAILED", e.message, null)
                    }
                } else {
                    pw.result.error(
                        "PERMISSION_DENIED",
                        "User denied write access to the media file",
                        null
                    )
                }
            }
            REQUEST_DELETE_PERMISSION -> {
                val res = pendingDeleteResult
                pendingDeleteResult = null
                if (resultCode == Activity.RESULT_OK) {
                    res?.success(null)
                } else {
                    res?.error("PERMISSION_DENIED", "User denied delete permission", null)
                }
            }
        }
    }

    /**
     * Performs the actual binary copy from [tempPath] into [mediaUri].
     * Caller must ensure write access has already been granted.
     */
    private fun doWrite(tempPath: String, mediaUri: Uri) {
        // "rwt" = read+write, truncate – binary safe
        contentResolver.openOutputStream(mediaUri, "rwt")?.use { out ->
            FileInputStream(File(tempPath)).use { input -> input.copyTo(out) }
        } ?: throw IllegalStateException("Could not open output stream for URI: $mediaUri")
    }

    /**
     * Resolves a MediaStore content URI from a filesystem path.
     */
    private fun getMediaUriForPath(path: String): Uri? {
        val projection = arrayOf(MediaStore.Audio.Media._ID)
        val selection = "${MediaStore.Audio.Media.DATA} = ?"
        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection, selection, arrayOf(path), null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
                return Uri.withAppendedPath(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()
                )
            }
        }
        return null
    }

    // -------------------------------------------------------------------------
    // Ringtone: set a song as the default phone ringtone
    // -------------------------------------------------------------------------

    private fun handleSetRingtone(path: String, result: MethodChannel.Result) {
        // On Android 6+ we need WRITE_SETTINGS (a special permission that is
        // not granted as a runtime permission — the user must enable it in Settings).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.System.canWrite(this)
        ) {
            // Open the "Modify system settings" page for the app so the user
            // can grant the permission, then return PERMISSION_NEEDED so the
            // Dart side can show a guiding snackbar.
            val intent = Intent(
                Settings.ACTION_MANAGE_WRITE_SETTINGS,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
            result.error("PERMISSION_NEEDED", "WRITE_SETTINGS permission required", null)
            return
        }

        try {
            val mediaUri = getMediaUriForPath(path)
                ?: run {
                    result.error("NOT_FOUND", "Could not locate song in MediaStore: $path", null)
                    return
                }

            // Mark the file as a ringtone in MediaStore so the system accepts it.
            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.IS_RINGTONE, true)
                put(MediaStore.Audio.Media.IS_NOTIFICATION, false)
                put(MediaStore.Audio.Media.IS_ALARM, false)
                put(MediaStore.Audio.Media.IS_MUSIC, false)
            }
            contentResolver.update(mediaUri, values, null, null)

            RingtoneManager.setActualDefaultRingtoneUri(
                this,
                RingtoneManager.TYPE_RINGTONE,
                mediaUri
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_RINGTONE_FAILED", e.message, null)
        }
    }

    // -------------------------------------------------------------------------
    // Delete: remove a song from the device via MediaStore
    // -------------------------------------------------------------------------

    private fun handleDeleteSong(path: String, result: MethodChannel.Result) {
        try {
            val mediaUri = getMediaUriForPath(path)
                ?: run {
                    result.error("NOT_FOUND", "Could not locate song in MediaStore: $path", null)
                    return
                }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Android 11+: createDeleteRequest shows the system confirmation dialog.
                pendingDeleteResult = result
                val intentSender =
                    MediaStore.createDeleteRequest(contentResolver, listOf(mediaUri))
                startIntentSenderForResult(
                    intentSender.intentSender, REQUEST_DELETE_PERMISSION, null, 0, 0, 0
                )
            } else {
                // Android 10 and below: direct delete via ContentResolver.
                val deleted = contentResolver.delete(mediaUri, null, null)
                if (deleted > 0) {
                    result.success(null)
                } else {
                    result.error("DELETE_FAILED", "ContentResolver.delete returned 0 rows", null)
                }
            }
        } catch (e: Exception) {
            result.error("DELETE_FAILED", e.message, null)
        }
    }
}
