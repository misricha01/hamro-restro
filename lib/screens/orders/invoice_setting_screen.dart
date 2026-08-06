import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/invoice_settings/invoice_settings_model.dart';
import '../../providers/invoice_settings_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/finance_form_fields.dart';
import '../../widgets/common/settings_section_tile.dart';

/// "Invoice Setting" reached from Orders' 3-dot Actions menu, and from
/// Manage > Setting > Order Setting. Backed by
/// [InvoiceSettingsProvider]/`/api/invoice/my`, which only supports a flat
/// set of ~20 boolean/string toggles. The original design's per-field
/// renaming, drag-reordering, QR upload, Invoice Type picker and Checkout
/// Action picker have no backend counterpart and have been dropped rather
/// than left as non-functional UI.
class InvoiceSettingScreen extends StatefulWidget {
  const InvoiceSettingScreen({super.key});

  @override
  State<InvoiceSettingScreen> createState() => _InvoiceSettingScreenState();
}

class _InvoiceSettingScreenState extends State<InvoiceSettingScreen> {
  late final _legalNameController = TextEditingController();
  late final _panController = TextEditingController();
  late final _footerRemarksController = TextEditingController();
  late InvoiceSettings _draft;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<InvoiceSettingsProvider>();
    _draft = provider.settings;
    WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchSettings());
  }

  void _syncControllersFrom(InvoiceSettings settings) {
    _legalNameController.text = settings.restaurantName ?? '';
    _panController.text = settings.panNo ?? '';
    _footerRemarksController.text = settings.footerRemarks ?? '';
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _panController.dispose();
    _footerRemarksController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final provider = context.read<InvoiceSettingsProvider>();
    final toSave = _draft.copyWith(
      restaurantName: _legalNameController.text.trim(),
      panNo: _panController.text.trim(),
      footerRemarks: _footerRemarksController.text.trim(),
    );
    final ok = await provider.saveSettings(toSave);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice settings saved')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.saveErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceSettingsProvider>();

    if (provider.status == LoadStatus.loaded && !_loadedOnce) {
      _loadedOnce = true;
      _draft = provider.settings;
      _syncControllersFrom(_draft);
    }

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
        title: const Text('Invoice Setting', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(InvoiceSettingsProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => provider.fetchSettings(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SettingsSectionTile(
                    title: 'Restaurant Information',
                    initiallyExpanded: true,
                    children: [
                      const FieldLabel(label: 'Restaurant Legal Name', required: false),
                      const SizedBox(height: 6),
                      AppTextField(controller: _legalNameController, hint: 'Enter legal name'),
                      const SizedBox(height: 14),
                      const FieldLabel(label: 'PAN Number', required: false),
                      const SizedBox(height: 6),
                      AppTextField(controller: _panController, hint: 'Enter PAN Number'),
                    ],
                  ),
                  SettingsSectionTile(
                    title: 'Invoice Header Details',
                    children: [
                      SettingsCheckRow(label: 'Invoice No', value: _draft.billNo, onChanged: (v) => setState(() => _draft = _draft.copyWith(billNo: v))),
                      SettingsCheckRow(label: 'Date', value: _draft.date, onChanged: (v) => setState(() => _draft = _draft.copyWith(date: v))),
                      SettingsCheckRow(label: 'Table No', value: _draft.tableNo, onChanged: (v) => setState(() => _draft = _draft.copyWith(tableNo: v))),
                    ],
                  ),
                  SettingsSectionTile(
                    title: 'Invoice Footer Details',
                    children: [
                      SettingsCheckRow(label: 'Payment Mode', value: _draft.paymentMode, onChanged: (v) => setState(() => _draft = _draft.copyWith(paymentMode: v)), highlighted: true),
                      SettingsCheckRow(label: 'Billed By', value: _draft.billBy, onChanged: (v) => setState(() => _draft = _draft.copyWith(billBy: v)), highlighted: true),
                      SettingsCheckRow(label: 'KOT Number', value: _draft.kotNumber, onChanged: (v) => setState(() => _draft = _draft.copyWith(kotNumber: v)), highlighted: true),
                      SettingsCheckRow(label: 'Total Amount', value: _draft.totalAmount, onChanged: (v) => setState(() => _draft = _draft.copyWith(totalAmount: v)), highlighted: true),
                      SettingsCheckRow(label: 'Amount In Words', value: _draft.amountInWords, onChanged: (v) => setState(() => _draft = _draft.copyWith(amountInWords: v)), highlighted: true),
                      SettingsCheckRow(label: 'Remarks', value: _draft.remarks, onChanged: (v) => setState(() => _draft = _draft.copyWith(remarks: v)), highlighted: true),
                    ],
                  ),
                  SettingsSectionTile(
                    title: 'Line Items',
                    children: [
                      SettingsCheckRow(label: 'S.N', value: _draft.sn, onChanged: (v) => setState(() => _draft = _draft.copyWith(sn: v))),
                      SettingsCheckRow(label: 'Particular', value: _draft.particular, onChanged: (v) => setState(() => _draft = _draft.copyWith(particular: v))),
                      SettingsCheckRow(label: 'Rate', value: _draft.rate, onChanged: (v) => setState(() => _draft = _draft.copyWith(rate: v))),
                      SettingsCheckRow(label: 'QTY', value: _draft.quantity, onChanged: (v) => setState(() => _draft = _draft.copyWith(quantity: v))),
                      SettingsCheckRow(label: 'Amount', value: _draft.amount, onChanged: (v) => setState(() => _draft = _draft.copyWith(amount: v))),
                    ],
                  ),
                  SettingsSectionTile(
                    title: 'Sub Total Calculation',
                    children: [
                      SettingsToggleRow(label: 'Customer Discount', value: _draft.customerDiscount, onChanged: (v) => setState(() => _draft = _draft.copyWith(customerDiscount: v))),
                      SettingsToggleRow(label: 'Sub Total', value: _draft.subTotal, onChanged: (v) => setState(() => _draft = _draft.copyWith(subTotal: v))),
                      SettingsToggleRow(label: 'Discount', value: _draft.discount, onChanged: (v) => setState(() => _draft = _draft.copyWith(discount: v))),
                      const SettingsGroupLabel(label: 'Taxable Amount'),
                      SettingsToggleRow(label: 'Tax Amount', value: _draft.taxAmount, onChanged: (v) => setState(() => _draft = _draft.copyWith(taxAmount: v))),
                      SettingsToggleRow(label: 'Taxable Amount', value: _draft.taxableAmount, onChanged: (v) => setState(() => _draft = _draft.copyWith(taxableAmount: v))),
                      SettingsToggleRow(label: 'Grand Total', value: _draft.grandTotal, onChanged: (v) => setState(() => _draft = _draft.copyWith(grandTotal: v))),
                    ],
                  ),
                  SettingsSectionTile(
                    title: 'Footer',
                    children: [
                      const Text('Remarks', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                      const SizedBox(height: 6),
                      AppTextField(controller: _footerRemarksController, hint: 'Enter Remarks', maxLines: 3, minLines: 2),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Discard', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                  const Spacer(),
                  SizedBox(
                    width: 170,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: provider.isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: provider.isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
