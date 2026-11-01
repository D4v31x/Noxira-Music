import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';
import '../../../shared/widgets/support_goal_card.dart';

/// "Support Noxira!" banner shown on the home app bar from time to time: a
/// frosted glass card with the monthly goal bar and Support / Close buttons.
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
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
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

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Align(
            alignment: const Alignment(0, 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: GlassDialogSurface(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SupportGoalTitle(fontSize: 20),
                      const SizedBox(height: 12),
                      const SupportGoalProgress(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SupportGlassButton(
                              primary: true,
                              label: l10n.supportButton,
                              onTap: () => _then(widget.onSupport),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SupportGlassButton(
                              label: l10n.close,
                              onTap: () => _then(widget.onClose),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
