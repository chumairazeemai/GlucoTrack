import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/export_sheet.dart';
import '../widgets/reading_card.dart';

class HistoryScreen extends StatefulWidget {
  final AppState state;
  const HistoryScreen({super.key, required this.state});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  static const _filters = <String, String>{
    'all': 'All',
    'today': 'Today',
    'fasting': 'Fasting Only',
    'non-fasting': 'Non-Fasting',
  };

  List<Reading> _filtered() {
    final all = widget.state.readings;
    final today = dateString(DateTime.now());
    switch (_filter) {
      case 'today':
        return all.where((r) => r.date == today).toList();
      case 'fasting':
        return all.where((r) => r.isFasting).toList();
      case 'non-fasting':
        return all.where((r) => !r.isFasting).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Complete Sugar Log',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate800)),
            FilledButton.tonalIcon(
              onPressed: () {
                if (widget.state.readings.isEmpty) {
                  showToast(context, 'No Data', 'Add readings before exporting.',
                      error: true);
                  return;
                }
                showExportSheet(context, widget.state);
              },
              icon: const Icon(Icons.ios_share, size: 16),
              label: const Text('Export',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2FE),
                foregroundColor: const Color(0xFF0369A1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final e in _filters.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _filter == e.key,
                    onSelected: (_) => setState(() => _filter = e.key),
                    showCheckmark: false,
                    selectedColor: AppColors.sky600,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: _filter == e.key
                            ? AppColors.sky600
                            : AppColors.slate200),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          _filter == e.key ? Colors.white : AppColors.slate500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No readings match this filter.',
                    style: TextStyle(fontSize: 12, color: AppColors.slate400)),
              ),
            ),
          )
        else
          for (final r in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReadingCard(reading: r, state: widget.state),
            ),
      ],
    );
  }
}
