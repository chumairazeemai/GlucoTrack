import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/reading_card.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onSeeAll;
  const DashboardScreen({super.key, required this.state, required this.onSeeAll});

  String _fmt(Averages a) => state.isMg ? '${a.mg}' : a.mmol.toStringAsFixed(1);
  String _alt(Averages a) =>
      state.isMg ? '= ${a.mmol.toStringAsFixed(1)} mmol/L' : '= ${a.mg} mg/dL';
  String get _unit => state.isMg ? 'mg/dL' : 'mmol/L';

  String _pair(Averages? a) {
    if (a == null) return '--';
    final mmol = a.mmol.toStringAsFixed(1);
    return state.isMg ? '${a.mg} mg/dL ($mmol)' : '$mmol mmol/L (${a.mg})';
  }

  @override
  Widget build(BuildContext context) {
    final today = AppState.average(state.todayReadings);
    final week = AppState.average(state.weekReadings);
    final fasting =
        AppState.average(state.weekReadings.where((r) => r.isFasting).toList());
    final nonFasting = AppState.average(
        state.weekReadings.where((r) => !r.isFasting).toList());
    final recent = state.readings.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AvgCard(
                title: "Today's Avg",
                icon: Icons.today,
                iconBg: const Color(0xFFF0F9FF),
                iconFg: const Color(0xFF0284C7),
                value: today == null ? '--' : _fmt(today),
                unit: _unit,
                secondary: today == null ? 'No readings today' : _alt(today),
                secondaryColor: const Color(0xFF0284C7),
                countLabel: '${today?.count ?? 0} reading${(today?.count ?? 0) == 1 ? '' : 's'}',
                status: today == null
                    ? null
                    : getSugarStatus(today.mg, 'non-fasting'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _AvgCard(
                title: '7-Day Avg',
                icon: Icons.date_range,
                iconBg: const Color(0xFFEEF2FF),
                iconFg: const Color(0xFF4F46E5),
                value: week == null ? '--' : _fmt(week),
                unit: _unit,
                secondary: week == null ? 'No data this week' : _alt(week),
                secondaryColor: const Color(0xFF4F46E5),
                countLabel: '${week?.count ?? 0} reading${(week?.count ?? 0) == 1 ? '' : 's'}',
                status: week == null
                    ? null
                    : getSugarStatus(week.mg, 'non-fasting'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Flexible(child: SectionLabel('7-Day Breakdown by Meal State')),
                  Text('Auto-converted',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.slate400)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MealBox(
                      color: const Color(0xFFB45309),
                      bg: const Color(0xFFFFFBEB),
                      border: const Color(0xFFFDE68A),
                      icon: Icons.wb_sunny,
                      title: 'Fasting Avg',
                      value: _pair(fasting),
                      target: state.isMg
                          ? 'Target: 70–99 mg/dL'
                          : 'Target: 3.9–5.5 mmol/L',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MealBox(
                      color: const Color(0xFF047857),
                      bg: const Color(0xFFECFDF5),
                      border: const Color(0xFFA7F3D0),
                      icon: Icons.restaurant,
                      title: 'Non-Fasting Avg',
                      value: _pair(nonFasting),
                      target: state.isMg
                          ? 'Target: < 140 mg/dL'
                          : 'Target: < 7.8 mmol/L',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _WeeklyChart(state: state),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Recent Sugar Readings',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate800)),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (recent.isEmpty)
          const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tap the + button below to add your first blood sugar reading.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.slate400),
                ),
              ),
            ),
          )
        else
          for (final r in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReadingCard(reading: r, state: state),
            ),
      ],
    );
  }
}

class _AvgCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String unit;
  final String secondary;
  final Color secondaryColor;
  final String countLabel;
  final SugarStatus? status;

  const _AvgCard({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.unit,
    required this.secondary,
    required this.secondaryColor,
    required this.countLabel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.slate400)),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 15, color: iconFg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate800)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(unit,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate400)),
              ),
            ],
          ),
          Text(secondary,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(countLabel,
                  style: const TextStyle(
                      fontSize: 10.5, color: AppColors.slate500)),
              Text(status?.label ?? '--',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: status?.bar ?? AppColors.slate400)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealBox extends StatelessWidget {
  final Color color;
  final Color bg;
  final Color border;
  final IconData icon;
  final String title;
  final String value;
  final String target;

  const _MealBox({
    required this.color,
    required this.bg,
    required this.border,
    required this.icon,
    required this.title,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800)),
          const SizedBox(height: 2),
          Text(target,
              style:
                  const TextStyle(fontSize: 10.5, color: AppColors.slate500)),
        ],
      ),
    );
  }
}

class _DayBar {
  final String label;
  final int avgMg;
  final double avgMmol;
  final int count;
  const _DayBar(this.label, this.avgMg, this.avgMmol, this.count);
}

class _WeeklyChart extends StatelessWidget {
  final AppState state;
  const _WeeklyChart({required this.state});

  @override
  Widget build(BuildContext context) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final days = <_DayBar>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final ds = dateString(d);
      final list = state.readings.where((r) => r.date == ds).toList();
      final avg = AppState.average(list);
      days.add(_DayBar(
        i == 0 ? 'Today' : names[d.weekday - 1],
        avg?.mg ?? 0,
        avg?.mmol ?? 0,
        list.length,
      ));
    }
    final maxMg = days.fold<int>(200, (m, d) => d.avgMg > m ? d.avgMg : m);
    const barArea = 62.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(child: SectionLabel('Last 7 Days Trend')),
              _Legend(),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          day.count == 0
                              ? '-'
                              : (state.isMg
                                  ? '${day.avgMg}'
                                  : day.avgMmol.toStringAsFixed(1)),
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: day.count == 0
                                  ? AppColors.slate300
                                  : AppColors.slate500),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 24,
                          height: day.count == 0
                              ? 8
                              : (day.avgMg / maxMg * barArea)
                                  .clamp(barArea * 0.18, barArea)
                                  .toDouble(),
                          decoration: BoxDecoration(
                            color: day.count == 0
                                ? AppColors.slate100
                                : getSugarStatus(day.avgMg, 'non-fasting').bar,
                            borderRadius: day.count == 0
                                ? BorderRadius.circular(8)
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(day.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: day.label == 'Today'
                                    ? AppColors.sky600
                                    : AppColors.slate400)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  Widget dot(Color c, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(t,
              style: TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w700, color: c)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(AppColors.emerald, 'Normal'),
        const SizedBox(width: 6),
        dot(AppColors.amber, 'Elevated'),
        const SizedBox(width: 6),
        dot(AppColors.rose, 'High/Low'),
      ],
    );
  }
}
