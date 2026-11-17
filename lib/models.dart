import 'package:flutter/material.dart';

/// 1 mmol/L = 18.0182 mg/dL
const double kConversionFactor = 18.0182;

double mgToMmol(num mg) =>
    double.parse((mg / kConversionFactor).toStringAsFixed(1));

int mmolToMg(num mmol) => (mmol * kConversionFactor).round();

String dateString(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

String timeString(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

// ---------------------------------------------------------------------------
// Colours
// ---------------------------------------------------------------------------
class AppColors {
  static const sky600 = Color(0xFF0284C7);
  static const blue700 = Color(0xFF1D4ED8);
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);
}

enum Tone { emerald, amber, rose }

class SugarStatus {
  final String label;
  final Tone tone;
  const SugarStatus(this.label, this.tone);

  Color get bar {
    switch (tone) {
      case Tone.emerald:
        return AppColors.emerald;
      case Tone.amber:
        return AppColors.amber;
      case Tone.rose:
        return AppColors.rose;
    }
  }

  Color get badgeBg {
    switch (tone) {
      case Tone.emerald:
        return const Color(0xFFD1FAE5);
      case Tone.amber:
        return const Color(0xFFFEF3C7);
      case Tone.rose:
        return const Color(0xFFFFE4E6);
    }
  }

  Color get badgeFg {
    switch (tone) {
      case Tone.emerald:
        return const Color(0xFF047857);
      case Tone.amber:
        return const Color(0xFFB45309);
      case Tone.rose:
        return const Color(0xFFBE123C);
    }
  }
}

SugarStatus getSugarStatus(num mg, String mealState) {
  if (mg < 70) return const SugarStatus('Low', Tone.rose);
  if (mealState == 'fasting') {
    if (mg <= 99) return const SugarStatus('Normal', Tone.emerald);
    if (mg <= 125) return const SugarStatus('Elevated', Tone.amber);
    return const SugarStatus('High', Tone.rose);
  } else {
    if (mg <= 140) return const SugarStatus('Normal', Tone.emerald);
    if (mg <= 180) return const SugarStatus('Elevated', Tone.amber);
    return const SugarStatus('High', Tone.rose);
  }
}

// ---------------------------------------------------------------------------
// Reading
// ---------------------------------------------------------------------------
class Reading {
  final int id;
  final int mg;
  final double mmol;
  final String mealState; // 'fasting' | 'non-fasting'
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String note;

  const Reading({
    required this.id,
    required this.mg,
    required this.mmol,
    required this.mealState,
    required this.date,
    required this.time,
    required this.note,
  });

  bool get isFasting => mealState == 'fasting';

  Map<String, dynamic> toJson() => {
        'id': id,
        'mg': mg,
        'mmol': mmol,
        'mealState': mealState,
        'date': date,
        'time': time,
        'note': note,
      };

  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
        id: (j['id'] as num).toInt(),
        mg: (j['mg'] as num).toInt(),
        mmol: (j['mmol'] as num).toDouble(),
        mealState: j['mealState'] as String,
        date: j['date'] as String,
        time: j['time'] as String,
        note: (j['note'] as String?) ?? '',
      );
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------
double calculateBmi(double weightKg, double heightCm) {
  final h = heightCm / 100;
  if (h <= 0) return 0;
  return double.parse((weightKg / (h * h)).toStringAsFixed(1));
}

String bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25.0) return 'Healthy Weight';
  if (bmi < 30.0) return 'Overweight';
  return 'Obesity Range';
}

class UserProfile {
  final String name;
  final int age;
  final double weight;
  final int height;
  final String gender;
  final String diabetesType;

  const UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.diabetesType,
  });

  static const defaults = UserProfile(
    name: 'Alex',
    age: 42,
    weight: 76,
    height: 175,
    gender: 'Male',
    diabetesType: 'Type 2',
  );

  double get bmi => calculateBmi(weight, height.toDouble());

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'diabetesType': diabetesType,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: (j['name'] as String?) ?? 'User',
        age: (j['age'] as num?)?.toInt() ?? 40,
        weight: (j['weight'] as num?)?.toDouble() ?? 75,
        height: (j['height'] as num?)?.toInt() ?? 175,
        gender: (j['gender'] as String?) ?? 'Male',
        diabetesType: (j['diabetesType'] as String?) ?? 'Type 2',
      );
}

String formatWeight(double w) =>
    w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toString();
