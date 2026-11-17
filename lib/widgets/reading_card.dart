import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'common.dart';

class ReadingCard extends StatelessWidget {
  final Reading reading;
  final AppState state;
  const ReadingCard({super.key, required this.reading, required this.state});

  @override
  Widget build(BuildContext context) {
    final r = reading;
    final st = getSugarStatus(r.mg, r.mealState);
    final isMg = state.isMg;
    final mmolText = r.mmol.toStringAsFixed(1);
    final primary = isMg ? '${r.mg} mg/dL' : '$mmolText mmol/L';
    final secondary = isMg ? '$mmolText mmol/L' : '${r.mg} mg/dL';

    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: st.badgeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isMg ? '${r.mg}' : mmolText,
                  style: TextStyle(
                      color: st.badgeFg,
                      fontWeight: FontWeight.w900,
                      fontSize: 13),
                ),
                Text(
                  isMg ? 'MG' : 'MMOL',
                  style: TextStyle(
                      color: st.badgeFg,
                      fontWeight: FontWeight.w700,
                      fontSize: 8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(primary,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.slate800)),
                    Text('($secondary)',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                            color: AppColors.slate400)),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _MealBadge(fasting: r.isFasting),
                    Text('${r.date} • ${r.time}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.slate400)),
                  ],
                ),
                if (r.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"${r.note}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.slate500)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: st.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(st.label,
                    style: TextStyle(
                        color: st.badgeFg,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5)),
              ),
              const SizedBox(height: 4),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _delete(context),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline,
                      size: 19, color: AppColors.slate300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context) {
    final removed = reading;
    state.deleteReading(removed.id);
    showToast(
      context,
      'Deleted',
      'Reading removed from your log.',
      action: SnackBarAction(
        label: 'UNDO',
        textColor: const Color(0xFF7DD3FC),
        onPressed: () => state.addReading(removed),
      ),
    );
  }
}

class _MealBadge extends StatelessWidget {
  final bool fasting;
  const _MealBadge({required this.fasting});

  @override
  Widget build(BuildContext context) {
    final bg = fasting ? const Color(0xFFFFFBEB) : const Color(0xFFF0F9FF);
    final fg = fasting ? const Color(0xFFB45309) : const Color(0xFF0369A1);
    final border =
        fasting ? const Color(0xFFFDE68A) : const Color(0xFFBAE6FD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fasting ? Icons.wb_sunny : Icons.restaurant,
              size: 11, color: fg),
          const SizedBox(width: 4),
          Text(fasting ? 'Fasting' : 'Non-Fasting',
              style: TextStyle(
                  color: fg, fontSize: 10.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
