import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'daybook_table.dart';

/// "Close Daybook" screen reached from the Daybook screen's "Close the Day"
/// button. Lets the user pick a closing date, add remarks, adjust account
/// balances and review the Finance-vs-Daybook difference before closing.
class CloseDaybookScreen extends StatefulWidget {
  const CloseDaybookScreen({super.key});

  @override
  State<CloseDaybookScreen> createState() => _CloseDaybookScreenState();
}

class _CloseDaybookScreenState extends State<CloseDaybookScreen> {
  DateTime _closeDate = DateTime.now();
  final TextEditingController _remarksController = TextEditingController();
  late final List<TextEditingController> _adjustControllers = List.generate(
    kDaybookAccountColumns.length,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    _remarksController.dispose();
    for (final c in _adjustControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _closeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _closeDate = result);
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _closeDaybook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daybook closed successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Close Daybook',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text(
            'Close Daybook',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Select one Date', required: true),
          const SizedBox(height: 8),
          _DateField(date: _formatDate(_closeDate), onTap: _pickDate),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _remarksController, hint: 'Enter your remarks'),
          const SizedBox(height: 20),

          DaybookSummaryTable(
            rows: buildDaybookBalanceRows(
              adjustBalanceControllers: _adjustControllers,
              includeDifference: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: ElevatedButton(
          onPressed: _closeDaybook,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.cancelled,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Close Daybook',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
        children: [
          TextSpan(text: label),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _AppTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String date;
  final VoidCallback onTap;
  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(
              child: Text(date, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
            ),
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
