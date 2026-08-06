import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../models/staff.dart';

enum _AdjustOption { reset, toCollect, toPay }

/// "Adjust Balance" screen reached from [StaffDetailScreen]'s "..." menu.
/// This backend has no ledger/balance concept for staff users, so the
/// balance/type here are local-only state owned by [StaffDetailScreen] (not
/// persisted, not read from [StaffMember]) — matches the reference's
/// Reset / To Collect / To Pay radio options with an inline amount field.
class AdjustBalanceScreen extends StatefulWidget {
  final StaffMember staff;
  final double currentBalance;
  final StaffBalanceType currentBalanceType;

  const AdjustBalanceScreen({
    super.key,
    required this.staff,
    this.currentBalance = 0,
    this.currentBalanceType = StaffBalanceType.toCollect,
  });

  @override
  State<AdjustBalanceScreen> createState() => _AdjustBalanceScreenState();
}

class _AdjustBalanceScreenState extends State<AdjustBalanceScreen> {
  late _AdjustOption _option = widget.currentBalanceType == StaffBalanceType.toPay ? _AdjustOption.toPay : _AdjustOption.toCollect;
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _isDirty = false;
  bool _amountError = false;
  bool _remarksError = false;

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _resetForm() {
    setState(() {
      _option = _AdjustOption.toPay;
      _amountController.clear();
      _remarksController.clear();
      _isDirty = false;
      _amountError = false;
      _remarksError = false;
    });
  }

  void _save() {
    setState(() {
      _amountError = _option != _AdjustOption.reset && _amountController.text.trim().isEmpty;
      _remarksError = _remarksController.text.trim().isEmpty;
    });
    if (_amountError || _remarksError) return;

    final amount = _option == _AdjustOption.reset ? 0.0 : (double.tryParse(_amountController.text.trim()) ?? 0);
    Navigator.pop(context, (balance: amount, balanceType: _option == _AdjustOption.toPay ? StaffBalanceType.toPay : StaffBalanceType.toCollect));
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
          'Adjust Balance',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _StaffMiniCard(staff: widget.staff, balance: widget.currentBalance, balanceType: widget.currentBalanceType),
          const SizedBox(height: 20),
          const Text('Select what you want to adjust:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          const SizedBox(height: 12),

          _AdjustOptionTile(
            title: 'Reset to 0.0',
            trailingIcon: Icons.arrow_downward,
            trailingColor: AppTheme.completed,
            selected: _option == _AdjustOption.reset,
            onTap: () => setState(() {
              _option = _AdjustOption.reset;
              _isDirty = true;
            }),
          ),
          if (_option == _AdjustOption.reset) ...[
            const SizedBox(height: 16),
            _remarksField(),
          ],
          const SizedBox(height: 12),

          _AdjustOptionTile(
            title: 'To Collect | Outstanding',
            trailingIcon: Icons.arrow_downward,
            trailingColor: AppTheme.completed,
            selected: _option == _AdjustOption.toCollect,
            onTap: () => setState(() {
              _option = _AdjustOption.toCollect;
              _isDirty = true;
            }),
          ),
          if (_option == _AdjustOption.toCollect) ...[
            const SizedBox(height: 16),
            _amountField(),
          ],
          const SizedBox(height: 12),

          _AdjustOptionTile(
            title: 'To Pay | Advanced',
            trailingIcon: Icons.arrow_upward,
            trailingColor: AppTheme.cancelled,
            selected: _option == _AdjustOption.toPay,
            onTap: () => setState(() {
              _option = _AdjustOption.toPay;
              _isDirty = true;
            }),
          ),
          if (_option == _AdjustOption.toPay) ...[
            const SizedBox(height: 16),
            _amountField(),
          ],
          const SizedBox(height: 20),
          _remarksField(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isDirty ? _resetForm : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  _isDirty ? 'Reset' : 'Back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelled,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
            children: [TextSpan(text: 'Enter Adjusted Balance'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _markDirty();
            if (_amountError && v.trim().isNotEmpty) setState(() => _amountError = false);
          },
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: InputDecoration(
            hintText: '00.00',
            prefixText: 'Rs   ',
            prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            errorText: _amountError ? 'Required' : null,
            filled: true,
            fillColor: AppTheme.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
          ),
        ),
      ],
    );
  }

  Widget _remarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
            children: [TextSpan(text: 'Remarks'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _remarksController,
          onChanged: (v) {
            _markDirty();
            if (_remarksError && v.trim().isNotEmpty) setState(() => _remarksError = false);
          },
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: InputDecoration(
            hintText: 'Enter your remarks',
            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            errorText: _remarksError ? 'Required' : null,
            filled: true,
            fillColor: AppTheme.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
          ),
        ),
      ],
    );
  }
}

class _AdjustOptionTile extends StatelessWidget {
  final String title;
  final IconData trailingIcon;
  final Color trailingColor;
  final bool selected;
  final VoidCallback onTap;

  const _AdjustOptionTile({required this.title, required this.trailingIcon, required this.trailingColor, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.completed : AppTheme.divider, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.completed : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none)),
                      const SizedBox(width: 6),
                      Icon(trailingIcon, color: trailingColor, size: 16),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('New Balance Will be 0.00', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffMiniCard extends StatelessWidget {
  final StaffMember staff;
  final double balance;
  final StaffBalanceType balanceType;
  const _StaffMiniCard({required this.staff, required this.balance, required this.balanceType});

  String get _initials {
    final parts = staff.fullname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final label = balanceType == StaffBalanceType.toCollect ? 'To Collect | Debit Balance' : 'To Pay | Advance Balance';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
            child: Text(_initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.fullname, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                const SizedBox(height: 4),
                Text('Rs ${balance.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
