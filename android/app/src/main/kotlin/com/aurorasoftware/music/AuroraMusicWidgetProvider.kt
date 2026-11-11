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
import android.os.Handler
import android.os.Looper
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.session.MediaControllerCompat
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
import kotlin.math.roundToInt

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
        const val ACTION_PLAY_SONG = "com.aurorasoftware.music.WIDGET_PLAY_SONG"
        const val EXTRA_SONG_ID = "song_id"
        const val ACTION_OPEN_APP = "com.aurorasoftware.music.WIDGET_OPEN"
        const val ACTION_UPDATE = "com.aurorasoftware.music.WIDGET_UPDATE"

        private const val AUDIO_SERVICE_CLASS = "com.ryanheise.audioservice.AudioService"
        private const val MEDIA_BUTTON_RECEIVER_CLASS =
            "com.ryanheise.audioservice.MediaButtonReceiver"

        private const val DEFAULT_TINT = 0xFF4F6D8F.toInt()
        private const val GLASS_RADIUS_DP = 28f
        private const val PAD_DP = 12
        private const val MAX_REC_ROWS = 4
        private const val MAX_REC_COLS = 6
        private const val QUEUE_CARD_DP = 44
        private const val REC_MAX_DP = 76
        private const val ROW_GAP_DP = 6

        // Decoded artwork and the drawn glass are reused between updates; the keys
        // include file timestamps so new art is picked up.
        private val bitmapCache = object : LruCache<String, Bitmap>(14 * 1024 * 1024) {
            override fun sizeOf(key: String, value: Bitmap) = value.byteCount
        }
    }

    // Layout variants, named after the design sheet: A..F are the 1-2 row
    // sizes, G/H/E the wider tall ones.
    private enum class Variant { A, B, F, C, D, G, H, E }

    private class RecCell(val cell: Int, val art: Int)

    private val recCells = arrayOf(
        arrayOf(RecCell(R.id.widget_rec_cell_0_0, R.id.widget_rec_art_0_0), RecCell(R.id.widget_rec_cell_0_1, R.id.widget_rec_art_0_1), RecCell(R.id.widget_rec_cell_0_2, R.id.widget_rec_art_0_2), RecCell(R.id.widget_rec_cell_0_3, R.id.widget_rec_art_0_3), RecCell(R.id.widget_rec_cell_0_4, R.id.widget_rec_art_0_4), RecCell(R.id.widget_rec_cell_0_5, R.id.widget_rec_art_0_5)),
        arrayOf(RecCell(R.id.widget_rec_cell_1_0, R.id.widget_rec_art_1_0), RecCell(R.id.widget_rec_cell_1_1, R.id.widget_rec_art_1_1), RecCell(R.id.widget_rec_cell_1_2, R.id.widget_rec_art_1_2), RecCell(R.id.widget_rec_cell_1_3, R.id.widget_rec_art_1_3), RecCell(R.id.widget_rec_cell_1_4, R.id.widget_rec_art_1_4), RecCell(R.id.widget_rec_cell_1_5, R.id.widget_rec_art_1_5)),
        arrayOf(RecCell(R.id.widget_rec_cell_2_0, R.id.widget_rec_art_2_0), RecCell(R.id.widget_rec_cell_2_1, R.id.widget_rec_art_2_1), RecCell(R.id.widget_rec_cell_2_2, R.id.widget_rec_art_2_2), RecCell(R.id.widget_rec_cell_2_3, R.id.widget_rec_art_2_3), RecCell(R.id.widget_rec_cell_2_4, R.id.widget_rec_art_2_4), RecCell(R.id.widget_rec_cell_2_5, R.id.widget_rec_art_2_5)),
        arrayOf(RecCell(R.id.widget_rec_cell_3_0, R.id.widget_rec_art_3_0), RecCell(R.id.widget_rec_cell_3_1, R.id.widget_rec_art_3_1), RecCell(R.id.widget_rec_cell_3_2, R.id.widget_rec_art_3_2), RecCell(R.id.widget_rec_cell_3_3, R.id.widget_rec_art_3_3), RecCell(R.id.widget_rec_cell_3_4, R.id.widget_rec_art_3_4), RecCell(R.id.widget_rec_cell_3_5, R.id.widget_rec_art_3_5)),
    )
    private val recRowIds = intArrayOf(R.id.widget_rec_row_0, R.id.widget_rec_row_1, R.id.widget_rec_row_2, R.id.widget_rec_row_3)

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
                    startPlayback(context, goAsync(), "play", null)
                }
            }
            ACTION_PLAY_SONG -> {
                val id = intent.getStringExtra(EXTRA_SONG_ID)
                if (id.isNullOrBlank()) return
                startPlayback(context, goAsync(), "play:$id", "song/$id")
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
        ).takeIf { it > 0 } ?: 192

        // Launcher cells are about 95dp wide/tall (minus a margin), so the
        // size in cells is recovered from the reported dp size.
        val cols = ((widthDp + 23) / 95f).roundToInt().coerceAtLeast(2)
        // Measured on the S25 Ultra: 1 row ~95dp, 2 rows ~190-210dp, 3 rows ~360dp.
        val rowCount = if (heightDp < 140) 1 else (heightDp - 140) / 150 + 2
        val variant = if (rowCount == 1) when {
            cols <= 2 -> Variant.A
            cols == 3 -> Variant.B
            else -> Variant.F
        } else when {
            cols <= 2 -> Variant.C
            cols == 3 -> Variant.D
            rowCount == 2 -> Variant.G
            cols == 4 -> Variant.H
            else -> Variant.E
        }

        val views = RemoteViews(context.packageName, R.layout.aurora_music_widget)

        val serviceRunning = isAudioServiceRunning(context)
        val rawTitle = prefs.getString("widget_song_title", null)
        val hasSong = !rawTitle.isNullOrBlank() && rawTitle != "Not Playing"
        val isPlaying = hasSong && serviceRunning && prefs.getBoolean("widget_is_playing", false)

        val tint = prefs.colorOrNull("widget_bg_color") ?: DEFAULT_TINT
        val artFile = prefs.getString("widget_artwork_path", null)?.takeIf { hasSong }

        // Glass card
        val widthPx = (widthDp * density).toInt().coerceAtLeast(1)
        val heightPx = (heightDp * density).toInt().coerceAtLeast(1)
        views.setImageViewBitmap(
            R.id.widget_bg,
            glassBackground(widthPx, heightPx, density, tint, artFile)
        )

        // ── Geometry (dp) ──
        val artDp = when (variant) {
            Variant.A, Variant.B, Variant.F -> 58
            Variant.C -> 62
            Variant.D, Variant.G -> 59
            Variant.H, Variant.E -> 80
        }
        val oneRow = rowCount == 1
        val sidePad = if (oneRow) 14 else PAD_DP
        val topPad = if (oneRow) ((heightDp - artDp) / 2).coerceAtLeast(6) else PAD_DP
        val innerW = widthDp - sidePad * 2
        views.setViewPadding(
            R.id.widget_content,
            (sidePad * density).toInt(), (topPad * density).toInt(),
            (sidePad * density).toInt(), (PAD_DP * density).toInt()
        )

        val showText = variant != Variant.A && variant != Variant.C
        val showControls = variant == Variant.B || variant == Variant.F
        val fullControls = variant == Variant.F
        val controlsRow = variant == Variant.D || variant == Variant.G ||
            variant == Variant.H || variant == Variant.E
        val controlsDp = when {
            !showControls -> 0
            fullControls -> 32 + 40 + 32
            else -> 40
        }
        // 26dp on the right is kept for the logo mark.
        val columnDp = innerW - artDp - 12 - controlsDp - 26

        // Track info (text is drawn into bitmaps with the app's typeface,
        // since launchers ignore custom fonts in RemoteViews).
        val title = if (hasSong) rawTitle!! else context.getString(R.string.widget_nothing_playing)
        val artist =
            if (hasSong) prefs.getString("widget_artist_name", "") ?: ""
            else context.getString(R.string.widget_tap_to_open)
        val dim = 0xB3FFFFFF.toInt()

        views.setViewVisibility(R.id.widget_text_col, if (showText) View.VISIBLE else View.GONE)
        if (showText) {
            text(context, views, R.id.widget_song_title, title, 16f, Color.WHITE, columnDp, 1)
            text(context, views, R.id.widget_artist_name, artist, 12f, dim, columnDp, 1)
        }
        val showInfo = variant == Variant.C
        views.setViewVisibility(R.id.widget_info, if (showInfo) View.VISIBLE else View.GONE)
        if (showInfo) {
            text(context, views, R.id.widget_info_title, title, 16f, Color.WHITE, innerW, 1)
            text(context, views, R.id.widget_info_artist, artist, 12f, dim, innerW, 1)
        }

        // Artwork + logo mark
        views.setImageViewBitmap(R.id.widget_art, artBitmap(context, artFile, (artDp * density).toInt()))
        views.setViewVisibility(R.id.widget_logo_top, if (variant == Variant.A) View.GONE else View.VISIBLE)
        views.setViewVisibility(R.id.widget_logo_mid, if (variant == Variant.A) View.VISIBLE else View.GONE)

        // Controls (plain white glyphs)
        val playRes = if (isPlaying) R.drawable.ic_wp_pause else R.drawable.ic_wp_play
        views.setViewVisibility(R.id.widget_controls, if (showControls) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_btn_prev, if (fullControls) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_btn_next, if (fullControls) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_btn_play_big, if (variant == Variant.C) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_controls_row, if (controlsRow) View.VISIBLE else View.GONE)
        views.setImageViewResource(R.id.widget_btn_play_row, playRes)
        views.setImageViewResource(R.id.widget_btn_play_pause, playRes)
        views.setImageViewResource(R.id.widget_btn_play_big, playRes)
        val canControl = serviceRunning && hasSong
        views.setOnClickPendingIntent(
            R.id.widget_btn_prev,
            if (canControl) broadcast(context, ACTION_PREVIOUS, 1) else launch(context, "open")
        )
        val playIntent =
            if (hasSong) broadcast(context, ACTION_PLAY_PAUSE, 2) else launch(context, "open")
        views.setOnClickPendingIntent(R.id.widget_btn_play_pause, playIntent)
        views.setOnClickPendingIntent(R.id.widget_btn_play_big, playIntent)
        views.setOnClickPendingIntent(R.id.widget_btn_play_row, playIntent)
        views.setOnClickPendingIntent(
            R.id.widget_btn_prev_row,
            if (canControl) broadcast(context, ACTION_PREVIOUS, 1) else launch(context, "open")
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_next_row,
            if (canControl) broadcast(context, ACTION_NEXT, 3) else launch(context, "open")
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_next,
            if (canControl) broadcast(context, ACTION_NEXT, 3) else launch(context, "open")
        )
        views.setOnClickPendingIntent(R.id.widget_root, launch(context, "open"))

        // Up next (wider, taller sizes only)
        val queueCards = when (variant) {
            Variant.H -> 1
            Variant.E -> 2
            Variant.D -> if (rowCount >= 3) 1 else 0
            else -> 0
        }
        val bigQueue = variant == Variant.D
        val cardDp = if (bigQueue) 60 else QUEUE_CARD_DP
        val queueDp = if (queueCards > 0) 8 + 16 + 4 + cardDp else 0
        bindQueue(context, views, prefs, density, innerW, queueCards, cardDp, bigQueue)

        // Recommendations fill whatever room is left, in as many rows as fit.
        val wantedRows = when (variant) {
            Variant.A, Variant.B, Variant.F -> 0
            Variant.C -> rowCount - 2
            Variant.D -> if (rowCount >= 3) rowCount - 2 else 1
            Variant.G -> 1
            Variant.H, Variant.E -> rowCount - 2
        }.coerceIn(0, MAX_REC_ROWS)
        val perRow = when {
            cols <= 2 -> 2
            cols == 3 -> 3
            cols <= 5 -> 4
            else -> MAX_REC_COLS
        }
        val fixedDp = PAD_DP + topPad + when (variant) {
            Variant.C -> artDp + 8 + 36 + 48
            else -> artDp
        } + (if (controlsRow) 48 else 0) + queueDp + 8
        val roomDp = heightDp - fixedDp
        // 3 columns with an up-next card: smaller art, wider spacing.
        val airy = variant == Variant.D && queueCards > 0
        val gapDp = if (airy) 14 else ROW_GAP_DP
        val maxArtDp = if (airy) 56 else REC_MAX_DP
        var recRows = wantedRows
        var recDp = 0
        while (recRows > 0) {
            val byHeight = (roomDp - gapDp * (recRows - 1)) / recRows
            val byWidth = innerW / perRow - 8
            recDp = minOf(byHeight, byWidth, maxArtDp)
            if (recDp >= 40) break
            recRows--
        }
        bindRecommendations(context, views, prefs, density, recRows, perRow, recDp, gapDp - ROW_GAP_DP)

        manager.updateAppWidget(appWidgetId, views)
    }

    private fun bindQueue(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        density: Float,
        innerW: Int,
        cards: Int,
        cardDp: Int,
        big: Boolean
    ) {
        views.setViewVisibility(R.id.widget_queue, if (cards > 0) View.VISIBLE else View.GONE)
        if (cards == 0) return
        val cardW = if (cards == 1) (innerW * (if (big) 0.82f else 0.5f)).toInt() else (innerW * 0.42f).toInt()
        val cols = arrayOf(R.id.widget_q_col_1 to R.id.widget_q_col_2)
        val labels = intArrayOf(R.id.widget_q_label_1, R.id.widget_q_label_2)
        val cardViews = intArrayOf(R.id.widget_q_card_1, R.id.widget_q_card_2)
        val labelRes = intArrayOf(R.string.widget_next_up, R.string.widget_after)
        views.setViewVisibility(cols[0].second, if (cards > 1) View.VISIBLE else View.GONE)
        if (prefs.getString("widget_q_1_title", null).isNullOrBlank()) {
            views.setViewVisibility(cols[0].first, View.VISIBLE)
            views.setViewVisibility(cols[0].second, View.GONE)
            text(context, views, labels[0], context.getString(R.string.widget_queue_empty), 12f,
                0xD9FFFFFF.toInt(), cardW, 1, Layout.Alignment.ALIGN_CENTER)
            views.setImageViewBitmap(cardViews[0], Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888))
            views.setOnClickPendingIntent(cardViews[0], null)
            return
        }
        for (i in 0 until 2) {
            if (i >= cards) continue
            val n = i + 1
            val title = prefs.getString("widget_q_${n}_title", null)
            val id = prefs.getString("widget_q_${n}_id", null)
            if (title.isNullOrBlank()) {
                views.setViewVisibility(if (i == 0) cols[0].first else cols[0].second, View.INVISIBLE)
                continue
            }
            views.setViewVisibility(if (i == 0) cols[0].first else cols[0].second, View.VISIBLE)
            text(context, views, labels[i], context.getString(labelRes[i]), 12f,
                0xD9FFFFFF.toInt(), cardW, 1, Layout.Alignment.ALIGN_CENTER)
            views.setImageViewBitmap(
                cardViews[i],
                queueCard(context, title, prefs.getString("widget_q_${n}_artist", "") ?: "",
                    cardW, cardDp, density, big)
            )
            if (!id.isNullOrBlank()) {
                views.setOnClickPendingIntent(cardViews[i], playSong(context, id))
            }
        }
    }

    private fun bindRecommendations(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        density: Float,
        rows: Int,
        perRow: Int,
        artDp: Int,
        extraGapDp: Int
    ) {
        views.setViewVisibility(R.id.widget_recs, if (rows > 0) View.VISIBLE else View.GONE)
        var shown = 0
        for (r in 0 until MAX_REC_ROWS) {
            val rowShown = r < rows
            views.setViewVisibility(recRowIds[r], if (rowShown) View.VISIBLE else View.GONE)
            views.setViewPadding(recRowIds[r], 0, if (r > 0) (extraGapDp * density).toInt() else 0, 0, 0)
            if (!rowShown) continue
            for (c in 0 until MAX_REC_COLS) {
                val cell = recCells[r][c]
                if (c >= perRow) {
                    views.setViewVisibility(cell.cell, View.GONE)
                    continue
                }
                val n = r * perRow + c + 1
                val id = prefs.getString("widget_rec_${n}_id", null)
                if (id.isNullOrBlank()) {
                    views.setViewVisibility(cell.cell, View.INVISIBLE)
                    continue
                }
                shown++
                views.setViewVisibility(cell.cell, View.VISIBLE)
                views.setImageViewBitmap(
                    cell.art,
                    artBitmap(context, prefs.getString("widget_rec_${n}_artwork", null),
                        (artDp * density).toInt())
                )
                views.setOnClickPendingIntent(cell.art, playSong(context, id))
            }
        }
        if (shown == 0) views.setViewVisibility(R.id.widget_recs, View.GONE)
    }

    /** Glass card (outlined, lightly filled) with a title and artist line. */
    private fun queueCard(
        context: Context,
        title: String,
        artist: String,
        widthDp: Int,
        heightDp: Int,
        density: Float,
        big: Boolean
    ): Bitmap {
        val w = max(1, (widthDp * density).toInt())
        val h = max(1, (heightDp * density).toInt())
        val key = "qcard|$title|$artist|$w|$h|$big"
        bitmapCache.get(key)?.let { return it }

        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        val radius = 14f * density
        val stroke = 1.2f * density
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = Color.argb(0x1A, 255, 255, 255)
        canvas.drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), radius, radius, paint)
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = stroke
        paint.color = Color.argb(0x73, 255, 255, 255)
        canvas.drawRoundRect(
            RectF(stroke / 2, stroke / 2, w - stroke / 2, h - stroke / 2),
            radius, radius, paint
        )

        val textW = (w - 20 * density).toInt().coerceAtLeast(1)
        fun layoutOf(value: String, sp: Float, color: Int): StaticLayout {
            val tp = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                typeface = appTypeface(context)
                textSize = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_SP, sp, context.resources.displayMetrics)
            }
            return StaticLayout.Builder.obtain(value, 0, value.length, tp, textW)
                .setMaxLines(1)
                .setEllipsize(TextUtils.TruncateAt.END)
                .setAlignment(Layout.Alignment.ALIGN_NORMAL)
                .build()
        }
        val t = layoutOf(title, if (big) 15f else 12.5f, Color.WHITE)
        val a = if (artist.isBlank()) null else layoutOf(artist, if (big) 12f else 10f, 0xB3FFFFFF.toInt())
        val total = t.height + (a?.height ?: 0)
        canvas.save()
        canvas.translate(10 * density, (h - total) / 2f)
        t.draw(canvas)
        if (a != null) {
            canvas.translate(0f, t.height.toFloat())
            a.draw(canvas)
        }
        canvas.restore()

        bitmapCache.put(key, out)
        return out
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

    /** Rounded-square artwork; songs without art get the app's "unknown" icon. */
    private fun artBitmap(context: Context, path: String?, sizePx: Int): Bitmap {
        val size = max(1, sizePx)
        val radius = size * 0.22f
        path?.takeIf { it.isNotBlank() }?.let { roundedSquare(it, size, radius) }?.let { return it }
        val key = "unknown|$size"
        bitmapCache.get(key)?.let { return it }
        val src = BitmapFactory.decodeResource(context.resources, R.drawable.widget_unknown)
        val out = drawRounded(src, size, radius)
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
        val out = drawRounded(src, sizePx, radiusPx)
        bitmapCache.put(key, out)
        return out
    }

    /** Centre-crops [src] into a [sizePx] square with rounded corners; recycles [src]. */
    private fun drawRounded(src: Bitmap, sizePx: Int, radiusPx: Float): Bitmap {
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

    private fun playSong(context: Context, id: String): PendingIntent {
        val intent = Intent(context, AuroraMusicWidgetProvider::class.java).apply {
            action = ACTION_PLAY_SONG
            data = Uri.parse("noxira://widget/play?id=$id")
            putExtra(EXTRA_SONG_ID, id)
        }
        return PendingIntent.getBroadcast(
            context, id.hashCode(), intent,
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

    /**
     * Starts playback without showing the app. Connecting to audio_service's
     * media browser wakes the app's process if needed (as Android Auto does);
     * a running player gets the command straight away, a cold one reads
     * [pending] from the widget preferences once it has loaded.
     */
    private fun startPlayback(
        context: Context,
        result: PendingResult?,
        pending: String,
        mediaId: String?
    ) {
        val running = isAudioServiceRunning(context)
        if (!running) {
            HomeWidgetPlugin.getData(context).edit()
                .putString("widget_pending_action", pending)
                .putLong("widget_pending_at", System.currentTimeMillis())
                .apply()
        }
        val app = context.applicationContext
        val main = Handler(Looper.getMainLooper())
        var browser: MediaBrowserCompat? = null
        var finished = false
        fun finish() {
            if (finished) return
            finished = true
            browser?.disconnect()
            result?.finish()
        }
        browser = MediaBrowserCompat(
            app,
            ComponentName(app, AUDIO_SERVICE_CLASS),
            object : MediaBrowserCompat.ConnectionCallback() {
                override fun onConnected() {
                    if (running) {
                        val controls = MediaControllerCompat(app, browser!!.sessionToken).transportControls
                        if (mediaId != null) controls.playFromMediaId(mediaId, null) else controls.play()
                    }
                    // Stay connected long enough for a cold start to finish loading.
                    main.postDelayed({ finish() }, if (running) 1500L else 8000L)
                }

                override fun onConnectionFailed() = finish()
            },
            null
        )
        browser.connect()
        main.postDelayed({ finish() }, 9000L)
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
