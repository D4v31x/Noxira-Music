import 'package:flutter/material.dart';

import '../../../core/constants/font_constants.dart';

/// A plain single-choice dialog; returns the picked value wrapped in a record
/// (so a null choice differs from a dismissed dialog), or null if dismissed.
Future<(T,)?> showOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
}) {
  return showDialog<(T,)>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        for (final (value, label) in options)
          RadioListTile<T>(
            value: value,
            groupValue: selected,
            title: Text(label,
                style: const TextStyle(fontFamily: FontConstants.fontFamily)),
            onChanged: (_) => Navigator.pop(ctx, (value,)),
          ),
      ],
    ),
  );
}
