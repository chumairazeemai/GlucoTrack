import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const _kReadings = 'glucotrack_readings_v1';
const _kProfile = 'glucotrack_profile_v1';
const _kUnit = 'glucotrack_unit_v1';

class Averages {
  final int mg;
  final double mmol;
  final int count;
  const Averages(this.mg, this.mmol, this.count);
}

class AppState extends ChangeNotifier {
  List<Reading> readings = [];
  UserProfile profile = UserProfile.defaults;
  String displayUnit = 'mg'; // 'mg' | 'mmol'
  bool loaded = false;

  bool get isMg => displayUnit == 'mg';

  // ---- persistence -------------------------------------------------------
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final r = prefs.getString(_kReadings);
      readings = r != null
          ? (jsonDecode(r) as List)
              .map((e) => Reading.fromJson(e as Map<String, dynamic>))
              .toList()
          : _defaultReadings();
      final p = prefs.getString(_kProfile);
      if (p != null) {
        profile = UserProfile.fromJson(jsonDecode(p) as Map<String, dynamic>);
      }
      final u = prefs.getString(_kUnit);
      if (u == 'mg' || u == 'mmol') displayUnit = u!;
    } catch (_) {
      readings = _defaultReadings();
    }
    _sort();
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kReadings, jsonEncode(readings.map((e) => e.toJson()).toList()));
      await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
      await prefs.setString(_kUnit, displayUnit);
    } catch (e) {
      debugPrint('Could not save: $e');
    }
  }

  void _sort() {
    readings.sort(
        (a, b) => '${b.date}T${b.time}'.compareTo('${a.date}T${a.time}'));
  }

  // ---- mutations ---------------------------------------------------------
  void setUnit(String unit) {
    displayUnit = unit;
    _save();
    notifyListeners();
  }

  void addReading(Reading r) {
    readings = [...readings, r];
    _sort();
    _save();
    notifyListeners();
  }

  void deleteReading(int id) {
    readings = readings.where((r) => r.id != id).toList();
    _save();
    notifyListeners();
  }

  void saveProfile(UserProfile p) {
    profile = p;
    _save();
    notifyListeners();
  }

  // ---- queries -----------------------------------------------------------
  List<Reading> get todayReadings {
    final today = dateString(DateTime.now());
    return readings.where((r) => r.date == today).toList();
  }

  List<Reading> get weekReadings {
    final now = DateTime.now();
    final today = dateString(now);
    final start = dateString(now.subtract(const Duration(days: 6)));
    return readings
        .where((r) =>
            r.date.compareTo(start) >= 0 && r.date.compareTo(today) <= 0)
        .toList();
  }

  static Averages? average(List<Reading> list) {
    if (list.isEmpty) return null;
    final mg = (list.fold<int>(0, (s, r) => s + r.mg) / list.length).round();
    final mmol = list.fold<double>(0, (s, r) => s + r.mmol) / list.length;
    return Averages(mg, mmol, list.length);
  }

  // ---- export ------------------------------------------------------------
  String buildCsv() {
    final b = StringBuffer(
        'Date,Time,Blood_Sugar_mg_dL,Blood_Sugar_mmol_L,Meal_State,Note\n');
    for (final r in readings) {
      final note = r.note.replaceAll(RegExp(r'[,\r\n]'), ' ');
      b.writeln('${r.date},${r.time},${r.mg},${r.mmol},${r.mealState},$note');
    }
    return b.toString();
  }

  String buildSummary() {
    final lines = <String>[
      'GlucoTrack Report — ${profile.name} (Age: ${profile.age}, Weight: ${formatWeight(profile.weight)}kg)',
      '----------------------------------------',
    ];
    for (final r in readings) {
      final note = r.note.isNotEmpty ? ' - ${r.note}' : '';
      lines.add(
          '${r.date} ${r.time} | ${r.mg} mg/dL (${r.mmol} mmol/L) | ${r.mealState}$note');
    }
    return lines.join('\n');
  }

  // ---- demo data (same sample readings as the web version) ---------------
  static List<Reading> _defaultReadings() {
    final now = DateTime.now();
    String d(int back) => dateString(now.subtract(Duration(days: back)));
    Reading r(int id, int mg, double mmol, String meal, int back, String time,
            String note) =>
        Reading(
          id: id,
          mg: mg,
          mmol: mmol,
          mealState: meal,
          date: d(back),
          time: time,
          note: note,
        );
    return [
      r(101, 96, 5.3, 'fasting', 0, '07:45', 'Morning fasting check'),
      r(102, 134, 7.4, 'non-fasting', 0, '13:30', '2 hrs after lunch'),
      r(103, 102, 5.7, 'fasting', 1, '08:00', 'Before breakfast'),
      r(104, 148, 8.2, 'non-fasting', 1, '20:15', 'After dinner'),
      r(105, 92, 5.1, 'fasting', 2, '07:30', ''),
      r(106, 126, 7.0, 'non-fasting', 3, '14:00', 'Post-lunch walk'),
      r(107, 112, 6.2, 'fasting', 4, '08:15', ''),
      r(108, 138, 7.7, 'non-fasting', 5, '19:45', ''),
    ];
  }
}
