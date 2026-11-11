package com.aurorasoftware.music

import android.content.Context
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.MediaRoute2Info
import android.media.MediaRouter2
import android.media.RouteDiscoveryPreference
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import com.ryanheise.just_audio.JustAudioPlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.WeakHashMap

/**
 * Lists the audio outputs the user can send playback to and switches between
 * them from inside the app.
 *
 * Switching sets the player's preferred audio device (`ExoPlayer
 * .setPreferredAudioDevice`), which sends this app's audio to that output
 * without any system UI. just_audio does not expose its ExoPlayer, so it is
 * reached through the plugin instance by reflection; the classes involved are
 * kept by proguard-rules.pro.
 *
 * Devices come from [AudioManager], which reliably lists every connected
 * output.
 */
class AudioOutputChannel(
    private val context: Context,
    private val engine: FlutterEngine,
) {
    companion object {
        const val CHANNEL = "aurora/audio_output"
        private const val REAPPLY_INTERVAL_MS = 2000L
    }

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val mainHandler = Handler(Looper.getMainLooper())

    /** The output the user picked, or null for the system's choice. */
    private var preferredDeviceId: Int? = null

    /** ExoPlayer instance -> device id it was last given. */
    private val appliedTo = WeakHashMap<Any, Int?>()

    // Only created on Android 14+. MediaRouter2.RouteCallback does not exist on
    // older versions, so nothing that extends it may be created on those.
    private var systemRouter: SystemRouter? = null

    private val deviceCallback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) {
            // A newly connected output takes over, like the system default does.
            if (addedDevices.any { it.isSink && kindOf(it) != null && kindOf(it) != "speaker" }) {
                setPreferred(null)
            }
        }

        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) {
            val id = preferredDeviceId ?: return
            if (removedDevices.any { it.id == id }) setPreferred(null)
        }
    }

    private val reapplyTask = object : Runnable {
        override fun run() {
            // ExoPlayers can be recreated (e.g. after a stop); keep them routed.
            applyToPlayers()
            if (preferredDeviceId != null) mainHandler.postDelayed(this, REAPPLY_INTERVAL_MS)
        }
    }

    init {
        audioManager.registerAudioDeviceCallback(deviceCallback, mainHandler)

        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getOutputs" -> result.success(getOutputs())
                    "selectOutput" -> {
                        val id = call.argument<String>("id")
                        result.success(id != null && selectOutput(id))
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("AUDIO_OUTPUT_ERROR", e.message, null)
            }
        }
    }

    fun dispose() {
        mainHandler.removeCallbacks(reapplyTask)
        audioManager.unregisterAudioDeviceCallback(deviceCallback)
        systemRouter?.dispose()
        systemRouter = null
    }

    private fun outputDevices(): List<Pair<AudioDeviceInfo, String>> =
        audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            .mapNotNull { device -> kindOf(device)?.let { kind -> device to kind } }
            // A headset can appear twice (A2DP + BLE); show it once.
            .distinctBy { (device, kind) -> kind to device.productName?.toString().orEmpty() }

    private fun getOutputs(): Map<String, Any> {
        val entries = outputDevices().map { (device, kind) ->
            OutputEntry(
                id = device.id.toString(),
                name = device.productName?.toString().orEmpty(),
                kind = kind,
            )
        }.toMutableList()

        if (entries.none { it.kind == "speaker" }) {
            entries += OutputEntry(id = "speaker", name = "", kind = "speaker")
        }

        // A preferred device that is gone no longer applies.
        val preferred = preferredDeviceId
        if (preferred != null && entries.none { it.id == preferred.toString() }) setPreferred(null)

        val selected = entries.firstOrNull { it.id == preferredDeviceId?.toString() }
            ?: selectedFromRouter(entries)
            ?: (entries.firstOrNull { it.kind != "speaker" } ?: entries.first())

        val outputs = entries.map { entry ->
            mapOf(
                "id" to entry.id,
                "name" to entry.name,
                "kind" to entry.kind,
                "selected" to (entry === selected),
            )
        }
        return mapOf("supportsSwitching" to true, "outputs" to outputs)
    }

    private class OutputEntry(val id: String, val name: String, val kind: String)

    private fun selectedFromRouter(entries: List<OutputEntry>): OutputEntry? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return null
        return try {
            val router = systemRouter ?: SystemRouter(context).also { systemRouter = it }
            val (routeType, routeName) = router.selectedRoute() ?: return null
            val kind = kindOf(routeType)
            entries.firstOrNull { it.kind == kind && it.name == routeName }
                ?: entries.firstOrNull { it.kind == kind && kind == "speaker" }
                ?: entries.firstOrNull { it.kind == kind }
        } catch (_: Exception) {
            null
        }
    }

    private fun kindOf(device: AudioDeviceInfo): String? = when (device.type) {
        AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> "speaker"
        AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
        AudioDeviceInfo.TYPE_BLE_HEADSET,
        AudioDeviceInfo.TYPE_BLE_SPEAKER,
        AudioDeviceInfo.TYPE_HEARING_AID -> "bluetooth"
        AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
        AudioDeviceInfo.TYPE_WIRED_HEADSET -> "wired"
        AudioDeviceInfo.TYPE_USB_DEVICE,
        AudioDeviceInfo.TYPE_USB_HEADSET -> "usb"
        else -> null
    }

    private fun kindOf(routeType: Int): String = when (routeType) {
        MediaRoute2Info.TYPE_BUILTIN_SPEAKER -> "speaker"
        MediaRoute2Info.TYPE_BLUETOOTH_A2DP,
        MediaRoute2Info.TYPE_HEARING_AID,
        MediaRoute2Info.TYPE_BLE_HEADSET -> "bluetooth"
        MediaRoute2Info.TYPE_WIRED_HEADPHONES,
        MediaRoute2Info.TYPE_WIRED_HEADSET -> "wired"
        MediaRoute2Info.TYPE_USB_DEVICE,
        MediaRoute2Info.TYPE_USB_HEADSET,
        MediaRoute2Info.TYPE_USB_ACCESSORY -> "usb"
        else -> "other"
    }

    /** Routes the app's audio to the output with [id]. Returns false if that isn't possible. */
    private fun selectOutput(id: String): Boolean {
        val device = outputDevices().map { it.first }.firstOrNull { it.id.toString() == id }
            ?: return false
        // The built-in speaker is the system's own pick when nothing else is
        // connected; an explicit choice is still honoured.
        setPreferred(device.id)
        return !exoPlayers().isEmpty() || preferredDeviceId == device.id
    }

    private fun setPreferred(deviceId: Int?) {
        preferredDeviceId = deviceId
        appliedTo.clear()
        applyToPlayers()
        mainHandler.removeCallbacks(reapplyTask)
        if (deviceId != null) mainHandler.postDelayed(reapplyTask, REAPPLY_INTERVAL_MS)
    }

    private fun applyToPlayers() {
        val id = preferredDeviceId
        val device = id?.let { wanted -> outputDevices().map { it.first }.firstOrNull { it.id == wanted } }
        if (id != null && device == null) return

        for (exo in exoPlayers()) {
            if (appliedTo.containsKey(exo) && appliedTo[exo] == id) continue
            try {
                Class.forName("androidx.media3.exoplayer.ExoPlayer")
                    .getMethod("setPreferredAudioDevice", AudioDeviceInfo::class.java)
                    .invoke(exo, device)
                appliedTo[exo] = id
            } catch (_: Exception) {
                // Leave it; the next pass tries again.
            }
        }
    }

    /** The ExoPlayer behind every live just_audio player (private plugin state). */
    private fun exoPlayers(): List<Any> {
        return try {
            val plugin = engine.plugins.get(JustAudioPlugin::class.java) ?: return emptyList()
            val handler = readField(plugin, "methodCallHandler") ?: return emptyList()
            val players = readField(handler, "players") as? Map<*, *> ?: return emptyList()
            players.values.mapNotNull { it?.let { player -> readField(player, "player") } }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun readField(target: Any, name: String): Any? {
        val field = target.javaClass.getDeclaredField(name)
        field.isAccessible = true
        return field.get(target)
    }
}

/**
 * The system's current route (Android 14+), kept apart from the rest of the
 * channel: it extends `MediaRouter2.RouteCallback`, a class that does not
 * exist before Android 11, so loading or creating it on an older phone would
 * crash the app at startup.
 */
@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
private class SystemRouter(private val context: Context) {
    private val callback = object : MediaRouter2.RouteCallback() {}
    private var registered = false

    private fun router(): MediaRouter2 {
        val router = MediaRouter2.getInstance(context)
        if (!registered) {
            // Without a registered callback and live-audio preference the
            // router reports no routes.
            router.registerRouteCallback(
                context.mainExecutor,
                callback,
                RouteDiscoveryPreference.Builder(
                    listOf(MediaRoute2Info.FEATURE_LIVE_AUDIO),
                    false,
                ).build(),
            )
            registered = true
        }
        return router
    }

    /** Type and name of the selected route, or null if there is none. */
    fun selectedRoute(): Pair<Int, String>? {
        val route = router().systemController.selectedRoutes.firstOrNull() ?: return null
        return route.type to route.name.toString()
    }

    fun dispose() {
        if (registered) {
            MediaRouter2.getInstance(context).unregisterRouteCallback(callback)
            registered = false
        }
    }
}
