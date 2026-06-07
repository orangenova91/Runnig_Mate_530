import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TimeChipSelector extends StatelessWidget {
  const TimeChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  static const _options = {
    'morning': '🌅 아침',
    'afternoon': '☀️ 오후',
    'night': '🌙 밤',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.entries.map((entry) {
        final isSelected = selected.contains(entry.key);
        return FilterChip(
          label: Text(
            entry.value,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          selectedColor: AppTheme.primary.withValues(alpha: 0.12),
          backgroundColor: AppTheme.surface,
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
          onSelected: (value) {
            final next = Set<String>.from(selected);
            value ? next.add(entry.key) : next.remove(entry.key);
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
