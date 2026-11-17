import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../models.dart';
import 'common.dart';

void showExportSheet(BuildContext context, AppState state) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _ExportSheet(state: state, parentContext: context),
  );
}

class _ExportSheet extends StatelessWidget {
  final AppState state;
  final BuildContext parentContext;
  const _ExportSheet({required this.state, required this.parentContext});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: state.buildSummary()));
    if (!context.mounted) return;
    Navigator.pop(context);
    if (parentContext.mounted) {
      showToast(parentContext, 'Copied!',
          'Report copied — paste it into WhatsApp or Email.');
    }
  }

  Future<void> _shareText() async {
    await Share.share(state.buildSummary(),
        subject: 'GlucoTrack Blood Sugar Report');
  }

  Future<void> _shareCsv(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/GlucoTrack_Report_${dateString(DateTime.now())}.csv');
      await file.writeAsString(state.buildCsv());
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'GlucoTrack Blood Sugar Report',
      );
    } catch (_) {
      if (parentContext.mounted) {
        showToast(parentContext, 'Could not create file',
            'Use Copy Text or Share Report instead.',
            error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: AppColors.sky600),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Export Blood Sugar Report',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Share your complete report with your doctor by WhatsApp or email, or send the CSV spreadsheet.',
              style: TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  state.buildSummary(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.slate800),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Text'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _shareCsv(context),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Share CSV'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sky600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _shareText,
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share via WhatsApp / Email'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
