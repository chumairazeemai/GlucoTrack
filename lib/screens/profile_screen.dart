import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late String _gender;
  late String _type;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _types = [
    'Type 2',
    'Type 1',
    'Pre-Diabetes',
    'Gestational',
    'General Wellness',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.state.profile;
    _name = TextEditingController(text: p.name);
    _age = TextEditingController(text: '${p.age}');
    _weight = TextEditingController(text: formatWeight(p.weight));
    _height = TextEditingController(text: '${p.height}');
    _gender = _genders.contains(p.gender) ? p.gender : _genders.first;
    _type = _types.contains(p.diabetesType) ? p.diabetesType : _types.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  double get _bmi {
    final w = double.tryParse(_weight.text) ?? 0;
    final h = double.tryParse(_height.text) ?? 0;
    return calculateBmi(w, h);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.state.saveProfile(UserProfile(
      name: _name.text.trim().isEmpty ? 'User' : _name.text.trim(),
      age: int.tryParse(_age.text) ?? 40,
      weight: double.tryParse(_weight.text) ?? 75,
      height: int.tryParse(_height.text) ?? 175,
      gender: _gender,
      diabetesType: _type,
    ));
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    if (ok) {
      showToast(context, 'Profile Saved',
          'Stored on this phone — it will be here next time.');
    } else {
      showToast(context, 'Could not save',
          'Your phone refused to store the profile. Please try again.',
          error: true);
    }
  }

  InputDecoration _dec() => InputDecoration(
        filled: true,
        fillColor: AppColors.slate50,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sky600, width: 1.6),
        ),
      );

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 5),
          child,
        ],
      );

  String? _range(String? v, num min, num max) {
    final n = num.tryParse(v ?? '');
    if (n == null || n < min || n > max) return '$min–$max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    const numStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate800);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          radius: 26,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.medical_services,
                          color: AppColors.sky600),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Health Profile',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slate800)),
                          Text('Used to personalize your health summary',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.slate400)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.slate100),
                _labeled(
                  'Full name',
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800),
                    decoration: _dec(),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _labeled(
                        'Age (yrs)',
                        TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: numStyle,
                          decoration: _dec(),
                          validator: (v) => _range(v, 1, 120),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labeled(
                        'Weight (kg)',
                        TextFormField(
                          controller: _weight,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          style: numStyle,
                          decoration: _dec(),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => _range(v, 20, 350),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labeled(
                        'Height (cm)',
                        TextFormField(
                          controller: _height,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: numStyle,
                          decoration: _dec(),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => _range(v, 80, 250),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _labeled(
                        'Gender',
                        DropdownButtonFormField<String>(
                          value: _gender,
                          isExpanded: true,
                          decoration: _dec(),
                          items: [
                            for (final g in _genders)
                              DropdownMenuItem(value: g, child: Text(g)),
                          ],
                          onChanged: (v) =>
                              setState(() => _gender = v ?? _gender),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labeled(
                        'Diabetes type',
                        DropdownButtonFormField<String>(
                          value: _type,
                          isExpanded: true,
                          decoration: _dec(),
                          items: [
                            for (final t in _types)
                              DropdownMenuItem(
                                  value: t,
                                  child: Text(t,
                                      overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() => _type = v ?? _type),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CALCULATED BMI',
                              style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate400)),
                          Text(bmiCategory(bmi),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF34D399))),
                        ],
                      ),
                      Text('$bmi',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFBBF24))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sky600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Save Health Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
