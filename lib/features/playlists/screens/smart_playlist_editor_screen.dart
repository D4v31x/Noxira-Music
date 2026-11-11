/// Editor for creating and modifying rule-based smart playlists.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/font_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/smart_playlist_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/expanding_player.dart';

/// Opens in "create" mode when [existing] is null, or "edit" mode to modify
/// an already-saved [SmartPlaylist].
class SmartPlaylistEditorScreen extends StatefulWidget {
  final SmartPlaylist? existing;

  const SmartPlaylistEditorScreen({super.key, this.existing});

  @override
  State<SmartPlaylistEditorScreen> createState() =>
      _SmartPlaylistEditorScreenState();
}

class _RuleDraft {
  SmartPlaylistField field;
  SmartPlaylistOperator operator;
  String value;

  _RuleDraft({required this.field, required this.operator, this.value = ''});

  SmartPlaylistRule toRule() =>
      SmartPlaylistRule(field: field, operator: operator, value: value);
}

class _SmartPlaylistEditorScreenState extends State<SmartPlaylistEditorScreen> {
  late final TextEditingController _nameController;
  late List<_RuleDraft> _rules;
  late SmartPlaylistMatchMode _matchMode;
  late SmartPlaylistSortBy _sortBy;
  int? _limit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _rules = existing != null
        ? existing.rules
            .map((r) => _RuleDraft(
                  field: r.field,
                  operator: r.operator,
                  value: r.value,
                ))
            .toList()
        : [
            _RuleDraft(
              field: SmartPlaylistField.playCount,
              operator: SmartPlaylistOperator.greaterThan,
              value: '5',
            ),
          ];
    _matchMode = existing?.matchMode ?? SmartPlaylistMatchMode.all;
    _sortBy = existing?.sortBy ?? SmartPlaylistSortBy.titleAZ;
    _limit = existing?.limit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _fieldLabel(SmartPlaylistField f) {
    final l10n = AppLocalizations.of(context);
    switch (f) {
      case SmartPlaylistField.title:
        return l10n.title;
      case SmartPlaylistField.artist:
        return l10n.artist;
      case SmartPlaylistField.album:
        return l10n.album;
      case SmartPlaylistField.genre:
        return l10n.genre;
      case SmartPlaylistField.folder:
        return l10n.smartFieldFolderPath;
      case SmartPlaylistField.liked:
        return l10n.smartFieldLiked;
      case SmartPlaylistField.playCount:
        return l10n.smartFieldPlayCount;
      case SmartPlaylistField.durationSeconds:
        return l10n.smartFieldDurationSeconds;
      case SmartPlaylistField.dateAddedDaysAgo:
        return l10n.smartFieldDaysSinceAdded;
    }
  }

  String _operatorLabel(SmartPlaylistOperator o) {
    final l10n = AppLocalizations.of(context);
    switch (o) {
      case SmartPlaylistOperator.contains:
        return l10n.smartOpContains;
      case SmartPlaylistOperator.notContains:
        return l10n.smartOpNotContains;
      case SmartPlaylistOperator.equals:
        return l10n.smartOpEquals;
      case SmartPlaylistOperator.notEquals:
        return l10n.smartOpNotEquals;
      case SmartPlaylistOperator.greaterThan:
        return l10n.smartOpGreaterThan;
      case SmartPlaylistOperator.lessThan:
        return l10n.smartOpLessThan;
      case SmartPlaylistOperator.isTrue:
        return l10n.smartOpIsTrue;
      case SmartPlaylistOperator.isFalse:
        return l10n.smartOpIsFalse;
    }
  }

  String _sortLabel(SmartPlaylistSortBy s) {
    final l10n = AppLocalizations.of(context);
    switch (s) {
      case SmartPlaylistSortBy.titleAZ:
        return l10n.smartSortTitleAZ;
      case SmartPlaylistSortBy.artistAZ:
        return l10n.smartSortArtistAZ;
      case SmartPlaylistSortBy.dateAddedNewest:
        return l10n.smartSortDateAddedNewest;
      case SmartPlaylistSortBy.playCountHighest:
        return l10n.smartSortPlayCountHighest;
      case SmartPlaylistSortBy.durationLongest:
        return l10n.smartSortDurationLongest;
      case SmartPlaylistSortBy.random:
        return l10n.smartSortRandom;
    }
  }

  List<SmartPlaylistOperator> _operatorsFor(SmartPlaylistField field) {
    switch (field.kind) {
      case SmartPlaylistFieldKind.text:
        return const [
          SmartPlaylistOperator.contains,
          SmartPlaylistOperator.notContains,
          SmartPlaylistOperator.equals,
          SmartPlaylistOperator.notEquals,
        ];
      case SmartPlaylistFieldKind.number:
        return const [
          SmartPlaylistOperator.greaterThan,
          SmartPlaylistOperator.lessThan,
          SmartPlaylistOperator.equals,
          SmartPlaylistOperator.notEquals,
        ];
      case SmartPlaylistFieldKind.boolean:
        return const [
          SmartPlaylistOperator.isTrue,
          SmartPlaylistOperator.isFalse,
        ];
    }
  }

  int _previewCount(AudioPlayerService audioService) {
    if (_rules.isEmpty) return audioService.songs.length;
    final rules = _rules.map((r) => r.toRule()).toList();
    return audioService.songs.where((song) {
      bool matches(SmartPlaylistRule r) => r.matches(
            song,
            isLiked: audioService.isLiked,
            playCountOf: audioService.playCountFor,
          );
      return _matchMode == SmartPlaylistMatchMode.all
          ? rules.every(matches)
          : rules.any(matches);
    }).length;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _rules.isEmpty || _saving) return;
    setState(() => _saving = true);

    final service = context.read<SmartPlaylistService>();
    final rules = _rules.map((r) => r.toRule()).toList();

    try {
      if (widget.existing != null) {
        await service.updateSmartPlaylist(widget.existing!.copyWith(
          name: name,
          rules: rules,
          matchMode: _matchMode,
          sortBy: _sortBy,
          limit: _limit,
          clearLimit: _limit == null,
        ));
      } else {
        await service.createSmartPlaylist(
          name: name,
          rules: rules,
          matchMode: _matchMode,
          sortBy: _sortBy,
          limit: _limit,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final audioService = context.watch<AudioPlayerService>();
    final preview = _previewCount(audioService);
    final canSave = _nameController.text.trim().isNotEmpty && _rules.isNotEmpty;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.existing != null
                ? l10n.editSmartPlaylist
                : l10n.createSmartPlaylist,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: canSave && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveSmartPlaylist,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, ExpandingPlayer.bottomInsetFor(context, idle: 32)),
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.smartPlaylistNameHint,
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _dropdownCard<SmartPlaylistMatchMode>(
                    value: _matchMode,
                    items: const [
                      SmartPlaylistMatchMode.all,
                      SmartPlaylistMatchMode.any,
                    ],
                    labelBuilder: (m) => m == SmartPlaylistMatchMode.all
                        ? l10n.matchAll
                        : l10n.matchAny,
                    onChanged: (m) => setState(() => _matchMode = m),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.smartPlaylistRules,
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 8),
            ..._rules.asMap().entries.map((entry) {
              final index = entry.key;
              final rule = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownCard<SmartPlaylistField>(
                            value: rule.field,
                            items: SmartPlaylistField.values,
                            labelBuilder: _fieldLabel,
                            onChanged: (f) => setState(() {
                              rule.field = f;
                              final validOps = _operatorsFor(f);
                              if (!validOps.contains(rule.operator)) {
                                rule.operator = validOps.first;
                              }
                            }),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white54),
                          onPressed: _rules.length > 1
                              ? () => setState(() => _rules.removeAt(index))
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _dropdownCard<SmartPlaylistOperator>(
                      value: rule.operator,
                      items: _operatorsFor(rule.field),
                      labelBuilder: _operatorLabel,
                      onChanged: (o) => setState(() => rule.operator = o),
                    ),
                    if (rule.field.kind != SmartPlaylistFieldKind.boolean) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: rule.value)
                          ..selection = TextSelection.collapsed(
                              offset: rule.value.length),
                        keyboardType:
                            rule.field.kind == SmartPlaylistFieldKind.number
                                ? const TextInputType.numberWithOptions(
                                    decimal: true)
                                : TextInputType.text,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => setState(() => rule.value = v),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _rules.add(_RuleDraft(
                    field: SmartPlaylistField.title,
                    operator: SmartPlaylistOperator.contains,
                  ))),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(l10n.addRule,
                  style: const TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context).sortBy,
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 8),
            _dropdownCard<SmartPlaylistSortBy>(
              value: _sortBy,
              items: SmartPlaylistSortBy.values,
              labelBuilder: _sortLabel,
              onChanged: (s) => setState(() => _sortBy = s),
            ),
            const SizedBox(height: 24),
            Text(l10n.limitResultsLabel,
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 8),
            _dropdownCard<int?>(
              value: _limit,
              items: const [null, 25, 50, 100, 200],
              labelBuilder: (v) => v == null ? l10n.noLimit : '$v',
              onChanged: (v) => setState(() => _limit = v),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.smartPlaylistPreviewCount(preview),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownCard<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.grey.shade900,
          iconEnabledColor: Colors.white70,
          style: const TextStyle(color: Colors.white),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v as T),
        ),
      ),
    );
  }
}
