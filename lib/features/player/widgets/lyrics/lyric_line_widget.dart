/// Lyric line widget.
///
/// Renders one sung line. Regular devices get left-set type where the active
/// line is full size and white, upcoming lines wait at a readable grey and
/// lines already sung drop back further. Low-end devices keep the original
/// centred, plain-text lines.
///
/// Motion adapted from musicfy (https://github.com/realidkroo/musicfy, GPL-3.0).
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurora_music_v01/core/constants/font_constants.dart';

import '../../../../shared/providers/performance_mode_provider.dart';
import 'lyrics_constants.dart';
import '../../../../shared/widgets/adaptive_blur.dart';

class _LineLook {
  const _LineLook(this.alpha, this.scale, this.blur);

  final double alpha;
  final double scale;
  final double blur;

  static _LineLook lerp(_LineLook a, _LineLook b, double t) => _LineLook(
        a.alpha + (b.alpha - a.alpha) * t,
        a.scale + (b.scale - a.scale) * t,
        a.blur + (b.blur - a.blur) * t,
      );
}

class _LineLookTween extends Tween<_LineLook> {
  _LineLookTween({super.end});

  @override
  _LineLook lerp(double t) => _LineLook.lerp(begin!, end!, t);
}

class LyricLineWidget extends StatelessWidget {
  const LyricLineWidget({
    super.key,
    required this.text,
    required this.isActive,
    required this.distance,
    this.isPast = false,
    this.subtitle,
    this.fontSize = 1.0,
    this.blurEnabled = true,
    this.onTap,
  });

  /// The text to display (the translation when one is shown).
  final String text;

  /// Original text shown small underneath while a translation is active.
  final String? subtitle;

  final bool isActive;

  /// Rows between this line and the focused one.
  final int distance;

  /// Whether the line has already been sung.
  final bool isPast;

  /// Font size multiplier.
  final double fontSize;

  final bool blurEnabled;
  final VoidCallback? onTap;

  _LineLook get _look {
    final alpha = isActive
        ? 1.0
        : isPast
            ? switch (distance) { 1 => 0.34, _ => 0.24 }
            : switch (distance) { 1 => 0.62, 2 => 0.48, _ => 0.38 };
    final blur = (!blurEnabled || isActive)
        ? 0.0
        : switch (distance) { <= 2 => 0.0, 3 => 2.0, 4 => 4.0, _ => 6.0 };
    return _LineLook(alpha, isActive ? 1.0 : 0.9, blur);
  }

  @override
  Widget build(BuildContext context) {
    final lowEnd = Provider.of<PerformanceModeProvider>(context, listen: false)
        .isLowEndDevice;
    return lowEnd ? _buildPlain() : _buildStyled();
  }

  /// The original lines: centred text that only changes style.
  Widget _buildPlain() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kLyricsHorizontalPadding,
        vertical: kLyricsLineSpacing / 2,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedDefaultTextStyle(
          duration: kLyricsScrollDuration,
          style: isActive
              ? lyricsCurrentLineStyle(sizeFactor: fontSize)
              : lyricsOtherLineStyle(sizeFactor: fontSize),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildStyled() {
    final style = TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: 32 * fontSize,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.18,
      letterSpacing: -0.6,
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: style),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle!,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: (style.fontSize! * 0.5).clamp(11.0, 15.0),
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.3,
              ),
            ),
          ),
      ],
    );

    return RepaintBoundary(
      child: TweenAnimationBuilder<_LineLook>(
        tween: _LineLookTween(end: _look),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, look, child) {
          return Opacity(
            opacity: look.alpha.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: look.scale,
              alignment: Alignment.centerLeft,
              child: AdaptiveImageFiltered(
                enabled: look.blur > 0.05,
                imageFilter: ImageFilter.blur(
                  sigmaX: look.blur,
                  sigmaY: look.blur,
                  tileMode: TileMode.decal,
                ),
                child: child,
              ),
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kLyricsHorizontalPadding,
              vertical: 11,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
