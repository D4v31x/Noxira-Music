import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../core/constants/font_constants.dart';
import '../../../shared/widgets/glassmorphic_dialog.dart';

/// A single-choice glass dialog; returns the picked value wrapped in a record
/// (so a null choice differs from a dismissed dialog), or null if dismissed.
Future<(T,)?> showOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
}) {
  return showDialog<(T,)>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (ctx) {
      return GlassmorphicDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (value, label) in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _OptionRow(
                    label: label,
                    selected: value == selected,
                    onTap: () => Navigator.pop(ctx, (value,)),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.16 : 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withValues(alpha: selected ? 0.45 : 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              if (selected)
                const iconoir.Check(color: Colors.white, width: 20, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
