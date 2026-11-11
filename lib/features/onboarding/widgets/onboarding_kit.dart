import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/font_constants.dart';
import 'onboarding_glass.dart';

export 'onboarding_glass.dart';

/// Shared building blocks of the onboarding: one type scale, one glass
/// surface, one entrance animation and one pair of buttons, so every step
/// reads as part of the same piece.

const double kOnboardingMargin = 24;

class OnboardingText {
  OnboardingText._();

  static const TextStyle headline = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 40,
    height: 1.04,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.4,
    color: Colors.white,
  );

  static const TextStyle lead = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 17,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: Color(0xB8FFFFFF),
  );

  static const TextStyle rowTitle = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle rowBody = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: Color(0xA3FFFFFF),
  );

  static const TextStyle small = TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: Color(0x8CFFFFFF),
  );
}

/// Scale-on-press wrapper shared by the buttons.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              unawaited(HapticFeedback.lightImpact());
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The one primary action of a step: a solid white pill.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return _Pressable(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.38 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: loading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.black87),
                  )
                : Text(
                    label,
                    key: ValueKey(label),
                    style: const TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// A quieter, glass button for secondary actions.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.order,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final int? order;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onPressed,
      child: GlassPanel(
        radius: 26,
        order: order,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: _Pressable(
        onTap: onPressed,
        child: const GlassPanel(
          radius: 29,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 58,
            height: 58,
            child: Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// A step: heading, lead text, content that scrolls, and a bottom bar with
/// Back and the primary action.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    this.lead,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryLoading = false,
    this.onBack,
    this.backLabel = 'Back',
    this.footnote,
    this.custom,
  });

  final String title;
  final String? lead;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final VoidCallback? onBack;
  final String backLabel;

  /// Quiet line above the buttons (a reminder, a note).
  final Widget? footnote;

  /// Replaces the standard heading and [children] with fully custom content.
  final List<Widget>? custom;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final header = <Widget>[
      Reveal(
        child: Text(title,
            textAlign: TextAlign.center, style: OnboardingText.headline),
      ),
      if (lead != null) ...[
        const SizedBox(height: 16),
        Reveal(
          order: 1,
          child: Text(lead!,
              textAlign: TextAlign.center, style: OnboardingText.lead),
        ),
      ],
    ];

    // Breathing room above and below, so a tall step still starts a good way
    // down the screen instead of at its very top.
    final inset = (MediaQuery.sizeOf(context).height * 0.06).clamp(24.0, 72.0);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = custom ??
                  <Widget>[...header, const SizedBox(height: 28), ...children];

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    kOnboardingMargin, inset, kOnboardingMargin, inset),
                physics: const BouncingScrollPhysics(),
                // The whole step (heading, text and content) is centred as one
                // block; when it is taller than the screen it simply scrolls.
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - inset * 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: content,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(kOnboardingMargin, 0, kOnboardingMargin,
              math.max(bottomInset, 16) + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (footnote != null) ...[
                ExitFade(child: footnote!),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  if (onBack != null) ...[
                    _BackButton(onPressed: onBack!, label: backLabel),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ExitFade(
                      child: PrimaryButton(
                        label: primaryLabel,
                        onPressed: onPrimary,
                        loading: primaryLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A slim, conventional onboarding progress track.
