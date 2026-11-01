package com.aurorasoftware.music

import android.app.ActivityManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import android.util.TypedValue
import android.net.Uri
import android.os.Bundle
import android.util.LruCache
import android.view.KeyEvent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File
import kotlin.math.max
import kotlin.math.min

/**
 * Home screen widget: a glass player card (artwork, title, controls)
 * that grows from a compact strip to a tall card with recommendations.
 *
 * The Flutter side writes the state into the home_widget preferences; this
 * class only renders it. Playback buttons talk to the running audio service
 * through media-button events, so they work without opening the app.
 */
class AuroraMusicWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.aurorasoftware.music.WIDGET_PLAY_PAUSE"
        const val ACTION_NEXT = "com.aurorasoftware.music.WIDGET_NEXT"
        const val ACTION_PREVIOUS = "com.aurorasoftware.music.WIDGET_PREVIOUS"
        const val ACTION_OPEN_APP = "com.aurorasoftware.music.WIDGET_OPEN"
        const val ACTION_UPDATE = "com.aurorasoftware.music.WIDGET_UPDATE"

        private const val AUDIO_SERVICE_CLASS = "com.ryanheise.audioservice.AudioService"
        private const val MEDIA_BUTTON_RECEIVER_CLASS =
            "com.ryanheise.audioservice.MediaButtonReceiver"

        private const val DEFAULT_TINT = 0xFF4F6D8F.toInt()
        private const val COMPACT_MAX_HEIGHT_DP = 150
        private const val LARGE_MIN_HEIGHT_DP = 255
        private const val GLASS_RADIUS_DP = 28f
        private const val REC_COUNT = 4

        private val RECS = arrayOf(
            Triple(R.id.widget_rec_1, R.id.widget_rec_art_1, R.id.widget_rec_title_1),
            Triple(R.id.widget_rec_2, R.id.widget_rec_art_2, R.id.widget_rec_title_2),
            Triple(R.id.widget_rec_3, R.id.widget_rec_art_3, R.id.widget_rec_title_3),
            Triple(R.id.widget_rec_4, R.id.widget_rec_art_4, R.id.widget_rec_title_4),
        )

        // Decoded artwork and the drawn glass are reused between updates; the keys
        // include file timestamps so new art is picked up.
        private val bitmapCache = object : LruCache<String, Bitmap>(14 * 1024 * 1024) {
            override fun sizeOf(key: String, value: Bitmap) = value.byteCount
        }
    }

    private enum class Size { COMPACT, REGULAR, LARGE }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PLAY_PAUSE -> {
                if (sendMediaKey(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)) {
                    // Flip the icon right away; Flutter confirms it a moment later.
                    val prefs = HomeWidgetPlugin.getData(context)
                    prefs.edit()
                        .putBoolean("widget_is_playing", !prefs.getBoolean("widget_is_playing", false))
                        .apply()
                    refreshAll(context)
                } else {
                    openApp(context)
                }
            }
            ACTION_NEXT -> if (!sendMediaKey(context, KeyEvent.KEYCODE_MEDIA_NEXT)) openApp(context)
            ACTION_PREVIOUS ->
                if (!sendMediaKey(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)) openApp(context)
            ACTION_OPEN_APP -> openApp(context)
            ACTION_UPDATE -> refreshAll(context)
        }
    }

    private fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, AuroraMusicWidgetProvider::class.java))
        for (id in ids) updateAppWidget(context, manager, id)
    }

    // ── Rendering ────────────────────────────────────────────────────────

    private fun updateAppWidget(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val density = context.resources.displayMetrics.density
        val options = manager.getAppWidgetOptions(appWidgetId)
        val landscape =
            context.resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
        val widthDp = options.getInt(
            if (landscape) AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH
            else AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
        ).takeIf { it > 0 } ?: 250
        val heightDp = options.getInt(
            if (landscape) AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
            else AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT
        ).takeIf { it > 0 } ?: 180

        val size = when {
            heightDp < COMPACT_MAX_HEIGHT_DP -> Size.COMPACT
            heightDp >= LARGE_MIN_HEIGHT_DP -> Size.LARGE
            else -> Size.REGULAR
        }
        val layoutRes = when (size) {
            Size.COMPACT -> R.layout.widget_music_compact
            Size.REGULAR -> R.layout.aurora_music_widget
            Size.LARGE -> R.layout.widget_music_large
        }
        val views = RemoteViews(context.packageName, layoutRes)

        val serviceRunning = isAudioServiceRunning(context)
        val rawTitle = prefs.getString("widget_song_title", null)
        val hasSong = !rawTitle.isNullOrBlank() && rawTitle != "Not Playing"
        val isPlaying = hasSong && serviceRunning && prefs.getBoolean("widget_is_playing", false)

        val tint = prefs.colorOrNull("widget_bg_color") ?: DEFAULT_TINT
        val accent = accentFor(tint)
        val artFile = prefs.getString("widget_artwork_path", null)?.takeIf { hasSong }

        // Glass card
        val widthPx = (widthDp * density).toInt().coerceAtLeast(1)
        val heightPx = (heightDp * density).toInt().coerceAtLeast(1)
        views.setImageViewBitmap(
            R.id.widget_bg,
            glassBackground(widthPx, heightPx, density, tint, artFile)
        )

        // Track info
        // The launcher ignores custom fonts in RemoteViews, so text is drawn into
        // bitmaps with the app's own typeface (Cal Sans).
        val columnDp = widthDp - (if (size == Size.COMPACT) 96 else 114) - 2
        val title = if (hasSong) rawTitle!! else context.getString(R.string.widget_nothing_playing)
        val artist =
            if (hasSong) prefs.getString("widget_artist_name", "") ?: ""
            else context.getString(R.string.widget_tap_to_open)
        val titleLines = if (size == Size.COMPACT) 1 else 2
        text(context, views, R.id.widget_song_title, title,
            if (size == Size.COMPACT) 16f else 18f, Color.WHITE, columnDp, titleLines)
        text(context, views, R.id.widget_artist_name, artist,
            if (size == Size.COMPACT) 13f else 14f, 0xB3FFFFFF.toInt(), columnDp, 1)
        if (size != Size.COMPACT) {
            val source = prefs.getString("widget_source", null)
                ?.takeIf { hasSong && it.isNotBlank() }
                ?: context.getString(R.string.widget_source_default)
            text(context, views, R.id.widget_source, source, 11f, 0x99FFFFFF.toInt(), columnDp, 1)
        }

        // Artwork
        val artDp = if (size == Size.COMPACT) 64 else 72
        val art = artFile?.let { roundedSquare(it, (artDp * density).toInt(), 18f * density) }
        if (art != null) {
            views.setImageViewBitmap(R.id.widget_art, art)
        } else {
            views.setImageViewResource(R.id.widget_art, R.drawable.widget_art_placeholder)
        }

        // Controls
        views.setInt(R.id.widget_play_bg, "setColorFilter", accent)
        views.setImageViewResource(
            R.id.widget_btn_play_pause,
            if (isPlaying) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
        )
        val canControl = serviceRunning && hasSong
        views.setOnClickPendingIntent(
            R.id.widget_btn_prev,
            if (canControl) broadcast(context, ACTION_PREVIOUS, 1) else launch(context, "open")
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_play_pause,
            if (canControl) broadcast(context, ACTION_PLAY_PAUSE, 2)
            else launch(context, if (hasSong) "resume" else "open")
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_next,
            if (canControl) broadcast(context, ACTION_NEXT, 3) else launch(context, "open")
        )
        views.setOnClickPendingIntent(R.id.widget_root, launch(context, "open"))

        if (size == Size.LARGE) bindRecommendations(context, views, prefs, density, widthDp)

        manager.updateAppWidget(appWidgetId, views)
    }

    private fun bindRecommendations(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        density: Float,
        widthDp: Int
    ) {
        val tileTextDp = (widthDp - 28) / REC_COUNT - 8
        text(context, views, R.id.widget_recs_label, context.getString(R.string.widget_recommended),
            12f, 0xB3FFFFFF.toInt(), widthDp - 30, 1)
        var shown = 0
        for (i in 0 until REC_COUNT) {
            val (tile, artView, titleView) = RECS[i]
            val n = i + 1
            val id = prefs.getString("widget_rec_${n}_id", null)
            val title = prefs.getString("widget_rec_${n}_title", null)
            if (id.isNullOrBlank() || title.isNullOrBlank()) {
                views.setViewVisibility(tile, View.INVISIBLE)
                continue
            }
            shown++
            views.setViewVisibility(tile, View.VISIBLE)
            text(context, views, titleView, title, 11f, 0xE6FFFFFF.toInt(), tileTextDp, 1,
                Layout.Alignment.ALIGN_CENTER)
            val art = prefs.getString("widget_rec_${n}_artwork", null)
                ?.let { roundedSquare(it, (48 * density).toInt(), 12f * density) }
            if (art != null) {
                views.setImageViewBitmap(artView, art)
            } else {
                views.setImageViewResource(artView, R.drawable.widget_art_placeholder)
            }
            views.setOnClickPendingIntent(tile, launch(context, "play?id=$id"))
        }
        views.setViewVisibility(R.id.widget_recs, if (shown > 0) View.VISIBLE else View.GONE)
    }


    // ── Text ─────────────────────────────────────────────────────────────

    private var typeface: Typeface? = null

    private fun appTypeface(context: Context): Typeface =
        typeface ?: (try {
            context.resources.getFont(R.font.cal_sans)
        } catch (e: Exception) {
            Typeface.DEFAULT
        }).also { typeface = it }

    /** Draws [text] with the app font into [viewId] (an ImageView) at a fixed width. */
    private fun text(
        context: Context,
        views: RemoteViews,
        viewId: Int,
        text: String,
        sizeSp: Float,
        color: Int,
        widthDp: Int,
        maxLines: Int,
        alignment: Layout.Alignment = Layout.Alignment.ALIGN_NORMAL
    ) {
        val metrics = context.resources.displayMetrics
        val widthPx = (widthDp * metrics.density).toInt().coerceAtLeast(1)
        val key = "text|$text|$sizeSp|$color|$widthPx|$maxLines|$alignment|${metrics.scaledDensity}"
        val bitmap = bitmapCache.get(key) ?: run {
            val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                typeface = appTypeface(context)
                textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sizeSp, metrics)
            }
            val layout = StaticLayout.Builder.obtain(text, 0, text.length, paint, widthPx)
                .setMaxLines(maxLines)
                .setEllipsize(TextUtils.TruncateAt.END)
                .setAlignment(alignment)
                .build()
            val out = Bitmap.createBitmap(widthPx, max(1, layout.height), Bitmap.Config.ARGB_8888)
            layout.draw(Canvas(out))
            bitmapCache.put(key, out)
            out
        }
        views.setImageViewBitmap(viewId, bitmap)
        views.setContentDescription(viewId, text)
    }

    // ── Drawing helpers ──────────────────────────────────────────────────

    /** Brightened artwork colour used for the play button. */
    private fun accentFor(tint: Int): Int {
        val hsv = FloatArray(3)
        Color.colorToHSV(tint, hsv)
        if (hsv[1] < 0.12f) {
            hsv[1] = 0f
        } else {
            hsv[1] = min(max(hsv[1], 0.35f), 0.7f)
        }
        hsv[2] = 0.96f
        return Color.HSVToColor(hsv)
    }

    /** Dark glass card washed with the artwork colours, like the app's backdrop. */
    private fun glassBackground(
        widthPx: Int,
        heightPx: Int,
        density: Float,
        tint: Int,
        artPath: String?
    ): Bitmap {
        val stamp = artPath?.let { File(it).lastModified() } ?: 0L
        val key = "glass|$widthPx|$heightPx|$tint|$artPath|$stamp"
        bitmapCache.get(key)?.let { return it }

        // Cap the size: a full-resolution card would be several megabytes.
        val scale = min(1f, 900f / max(widthPx, heightPx))
        val w = max(1, (widthPx * scale).toInt())
        val h = max(1, (heightPx * scale).toInt())
        val d = density * scale

        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        val rect = RectF(0f, 0f, w.toFloat(), h.toFloat())
        val radius = GLASS_RADIUS_DP * d
        canvas.save()
        canvas.clipPath(Path().apply { addRoundRect(rect, radius, radius, Path.Direction.CW) })
        canvas.drawColor(Color.argb(0xF2, 0x0C, 0x10, 0x16))

        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        val art = artPath?.let { decodeSampled(it, 48) }
        if (art != null) {
            // Shrinking then stretching with filtering gives a cheap heavy blur.
            val tiny = Bitmap.createScaledBitmap(art, 12, 12, true)
            val soft = Bitmap.createScaledBitmap(tiny, 48, 48, true)
            paint.alpha = 140
            canvas.drawBitmap(soft, null, RectF(-w * 0.2f, -h * 0.3f, w * 1.2f, h * 1.3f), paint)
            paint.alpha = 255
            tiny.recycle()
            soft.recycle()
            art.recycle()
        }

        paint.shader = RadialGradient(
            w * 0.15f, 0f, w * 0.95f,
            intArrayOf(withAlpha(tint, 0x70), withAlpha(tint, 0x00)),
            null, Shader.TileMode.CLAMP
        )
        canvas.drawRect(rect, paint)

        paint.shader = LinearGradient(
            0f, 0f, 0f, h.toFloat(),
            Color.argb(0x5C, 0, 0, 0), Color.argb(0xC0, 6, 8, 12),
            Shader.TileMode.CLAMP
        )
        canvas.drawRect(rect, paint)

        paint.shader = LinearGradient(
            0f, 0f, 0f, h * 0.35f,
            Color.argb(0x26, 255, 255, 255), Color.argb(0x00, 255, 255, 255),
            Shader.TileMode.CLAMP
        )
        canvas.drawRect(rect, paint)
        paint.shader = null
        canvas.restore()

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 1.2f * d
        paint.color = Color.argb(0x3A, 255, 255, 255)
        val inset = paint.strokeWidth / 2
        canvas.drawRoundRect(
            RectF(inset, inset, w - inset, h - inset),
            radius - inset, radius - inset, paint
        )

        bitmapCache.put(key, out)
        return out
    }

    private fun roundedSquare(path: String, sizePx: Int, radiusPx: Float): Bitmap? {
        if (sizePx <= 0) return null
        val file = File(path)
        if (!file.exists()) return null
        val key = "art|$path|${file.lastModified()}|$sizePx"
        bitmapCache.get(key)?.let { return it }

        val src = decodeSampled(path, sizePx) ?: return null
        val out = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val scale = max(sizePx / src.width.toFloat(), sizePx / src.height.toFloat())
        val shader = BitmapShader(src, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        shader.setLocalMatrix(Matrix().apply {
            setScale(scale, scale)
            postTranslate((sizePx - src.width * scale) / 2, (sizePx - src.height * scale) / 2)
        })
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        paint.shader = shader
        Canvas(out).drawRoundRect(
            RectF(0f, 0f, sizePx.toFloat(), sizePx.toFloat()), radiusPx, radiusPx, paint
        )
        src.recycle()
        bitmapCache.put(key, out)
        return out
    }

    private fun decodeSampled(path: String, targetPx: Int): Bitmap? {
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
            var sample = 1
            while (bounds.outWidth / (sample * 2) >= targetPx &&
                bounds.outHeight / (sample * 2) >= targetPx
            ) sample *= 2
            BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample })
        } catch (e: Exception) {
            null
        }
    }

    private fun withAlpha(color: Int, alpha: Int) =
        Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))

    // ── Preferences ──────────────────────────────────────────────────────

    // Dart ints above 2^31 (ARGB colours) arrive as Long, smaller ones as Int.
    private fun SharedPreferences.colorOrNull(key: String): Int? =
        (all[key] as? Number)?.toInt()

    // ── Intents ──────────────────────────────────────────────────────────

    private fun broadcast(context: Context, action: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, AuroraMusicWidgetProvider::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /** Opens the app; Flutter reads the `noxira://widget/...` URI to act on it. */
    private fun launch(context: Context, path: String): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java, Uri.parse("noxira://widget/$path")
        )

    private fun openApp(context: Context) {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(launchIntent)
        }
    }

    /** Same key events the media notification sends to audio_service. */
    private fun sendMediaKey(context: Context, keyCode: Int): Boolean {
        if (!isAudioServiceRunning(context)) return false
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            component = ComponentName(context, MEDIA_BUTTON_RECEIVER_CLASS)
            putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        }
        context.sendBroadcast(intent)
        return true
    }

    @Suppress("DEPRECATION")
    private fun isAudioServiceRunning(context: Context): Boolean {
        val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        // Only the app's own services are returned on modern Android, which is all we need.
        return manager.getRunningServices(Int.MAX_VALUE)
            .any { it.service.className == AUDIO_SERVICE_CLASS }
    }
}
