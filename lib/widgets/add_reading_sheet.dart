import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../models.dart';
import 'common.dart';

void showAddReadingSheet(BuildContext context, AppState state) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => AddReadingSheet(state: state, parentContext: context),
  );
}

class AddReadingSheet extends StatefulWidget {
  final AppState state;
  final BuildContext parentContext;
  const AddReadingSheet(
      {super.key, required this.state, required this.parentContext});

  @override
  State<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<AddReadingSheet> {
  final _mgCtrl = TextEditingController();
  final _mmolCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _meal = 'fasting';
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _time = TimeOfDay.fromDateTime(now);
  }

  @override
  void dispose() {
    _mgCtrl.dispose();
    _mmolCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onMg(String v) {
    final n = double.tryParse(v);
    // Programmatic text changes do not trigger onChanged on the other field.
    _mmolCtrl.text = (n != null && n > 0) ? mgToMmol(n).toStringAsFixed(1) : '';
    setState(() {});
  }

  void _onMmol(String v) {
    final n = double.tryParse(v);
    _mgCtrl.text = (n != null && n > 0) ? '${mmolToMg(n)}' : '';
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final mg = double.tryParse(_mgCtrl.text);
    final mmol = double.tryParse(_mmolCtrl.text);
    if (mg == null || mg <= 0 || mmol == null) {
      showToast(context, 'Missing Value', 'Please enter a blood sugar number.',
          error: true);
      return;
    }
    final reading = Reading(
      id: DateTime.now().millisecondsSinceEpoch,
      mg: mg.round(),
      mmol: double.parse(mmol.toStringAsFixed(1)),
      mealState: _meal,
      date: dateString(_date),
      time: timeString(_time),
      note: _noteCtrl.text.trim(),
    );
    widget.state.addReading(reading);
    final parent = widget.parentContext;
    Navigator.pop(context);
    if (parent.mounted) {
      showToast(parent, 'Reading Recorded!',
          '${reading.mg} mg/dL (${reading.mmol.toStringAsFixed(1)} mmol/L) saved.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mg = double.tryParse(_mgCtrl.text);
    final mmol = double.tryParse(_mmolCtrl.text);
    final hasValue = mg != null && mg > 0 && mmol != null;
    final status = hasValue ? getSugarStatus(mg!, _meal) : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.rose),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Log Blood Sugar',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.slate100),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SectionLabel('Enter in either unit'),
                      Text('Auto-converts',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sky600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          controller: _mgCtrl,
                          label: 'mg/dL (US / Standard)',
                          hint: 'e.g. 110',
                          decimal: false,
                          autofocus: widget.state.isMg,
                          onChanged: _onMg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          controller: _mmolCtrl,
                          label: 'mmol/L (UK / EU)',
                          hint: 'e.g. 6.1',
                          decimal: true,
                          autofocus: !widget.state.isMg,
                          onChanged: _onMmol,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                    decoration: BoxDecoration(
                      color: status?.badgeBg ?? AppColors.slate200,
                      borderRadius: BorderRadius.circular(12),
                      border: status == null
                          ? null
                          : Border.all(color: status.bar.withAlpha(110)),
                    ),
                    child: Text(
                      status == null
                          ? 'Type a value above to see instant conversion & range status'
                          : '${mg!.round()} mg/dL = ${mmol!.toStringAsFixed(1)} mmol/L • ${status.label} (${_meal == 'fasting' ? 'Fasting' : 'Non-Fasting'})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: status?.badgeFg ?? AppColors.slate500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('Meal condition'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MealOption(
                    selected: _meal == 'fasting',
                    icon: Icons.wb_sunny,
                    iconColor: AppColors.amber,
                    activeBorder: AppColors.amber,
                    activeBg: const Color(0xFFFFFBEB),
                    title: 'Fasting',
                    subtitle: 'Before meal (8h+ fast)',
                    onTap: () => setState(() => _meal = 'fasting'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MealOption(
                    selected: _meal == 'non-fasting',
                    icon: Icons.restaurant,
                    iconColor: AppColors.emerald,
                    activeBorder: AppColors.emerald,
                    activeBg: const Color(0xFFECFDF5),
                    title: 'Non-Fasting',
                    subtitle: 'After meal / Random',
                    onTap: () => setState(() => _meal = 'non-fasting'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    label: 'Date',
                    value: dateString(_date),
                    icon: Icons.calendar_today,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerTile(
                    label: 'Time',
                    value: timeString(_time),
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionLabel('Note (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 13),
              decoration: _fieldDecoration(
                  'e.g. Morning check, after breakfast, felt dizzy...'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save Sugar Reading',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sky600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.slate400),
      filled: true,
      fillColor: AppColors.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool decimal;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.decimal,
    required this.autofocus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.slate500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
          ],
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.slate800),
          decoration: _fieldDecoration(hint).copyWith(fillColor: Colors.white),
        ),
      ],
    );
  }
}

class _MealOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final Color activeBorder;
  final Color activeBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MealOption({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.activeBorder,
    required this.activeBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? activeBorder : AppColors.slate200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppColors.slate800)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.slate500)),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.slate500),
                const SizedBox(width: 8),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
