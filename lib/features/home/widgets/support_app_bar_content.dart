import 'package:flutter/material.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/support_goal_card.dart';

/// "Support Noxira!" reminder on the home app bar. Deliberately quiet: no card
/// or surface, just a line of text, a hairline goal bar and two plain text
/// actions sitting on the app bar background.
class SupportAppBarContent extends StatefulWidget {
  const SupportAppBarContent({
    super.key,
    required this.onSupport,
    required this.onClose,
  });

  final VoidCallback onSupport;
  final VoidCallback onClose;

  @override
  State<SupportAppBarContent> createState() => _SupportAppBarContentState();
}

class _SupportAppBarContentState extends State<SupportAppBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<void> _then(VoidCallback callback) async {
    await _entry.reverse();
    if (mounted) callback();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: Align(
          alignment: const Alignment(0, 0.05),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.supportNoxiraTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const SupportGoalProgress(centered: true, compact: true),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TextAction(
                      label: l10n.supportButton,
                      color: primary,
                      bold: true,
                      onTap: () => _then(widget.onSupport),
                    ),
                    const SizedBox(width: 8),
                    _TextAction(
                      label: l10n.close,
                      color: Colors.white.withValues(alpha: 0.5),
                      onTap: () => _then(widget.onClose),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain text with a comfortable tap area; no fill, border or shadow.
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final Color color;
  final bool bold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            color: color,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
