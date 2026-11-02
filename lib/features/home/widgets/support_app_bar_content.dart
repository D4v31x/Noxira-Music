import 'package:flutter/material.dart';

import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/support_goal_card.dart';

/// "Support Noxira!" reminder on the home app bar. There is no card behind it:
/// the goal bar and the two buttons are frosted glass pieces of their own,
/// floating on the app bar background.
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
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.supportNoxiraTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite_rounded, color: primary, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                const SupportGoalProgress(centered: true, compact: true),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SupportGlassButton(
                      pill: true,
                      primary: true,
                      label: l10n.supportButton,
                      onTap: () => _then(widget.onSupport),
                    ),
                    const SizedBox(width: 10),
                    SupportGlassButton(
                      pill: true,
                      label: l10n.close,
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
