import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tax_rate.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/setting_empty_state.dart';
import 'add_tax_screen.dart';

/// "Tax & Rates" screen reached from Manage > Setting > Order Setting: manage
/// VAT/tax rates. Shows the empty state until the first tax is created,
/// matching the reference.
class TaxRatesScreen extends StatefulWidget {
  const TaxRatesScreen({super.key});

  @override
  State<TaxRatesScreen> createState() => _TaxRatesScreenState();
}

class _TaxRatesScreenState extends State<TaxRatesScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  final List<TaxRate> _taxes = [];

  List<TaxRate> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _taxes;
    return _taxes.where((t) => t.name.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createTax() async {
    final tax = await Navigator.push<TaxRate>(context, MaterialPageRoute(builder: (context) => const AddTaxScreen()));
    if (tax != null) setState(() => _taxes.add(tax));
  }

  Future<void> _editTax(int index) async {
    final updated = await Navigator.push<TaxRate>(context, MaterialPageRoute(builder: (context) => AddTaxScreen(initial: _taxes[index])));
    if (updated != null) setState(() => _taxes[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final taxes = _filtered;
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
        title: const Text('Tax & Rates', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searching, onTap: () => setState(() => _searching = !_searching)),
          ManageAppBarIconButton(icon: Icons.more_horiz, bordered: true, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening help article...')))),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searching)
              ManageSearchField(
                controller: _searchController,
                onClose: () => setState(() { _searching = false; _searchController.clear(); }),
                onChanged: (_) => setState(() {}),
              ),
            Expanded(
              child: taxes.isEmpty
                  ? SettingEmptyState(
                      title: 'Tax',
                      subtitle: 'No Tax found. Needs to create the Tax!',
                      actionLabel: 'Create New Tax',
                      onAction: _createTax,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
                      itemCount: taxes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tax = taxes[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _editTax(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                            child: Row(
                              children: [
                                const Icon(Icons.percent, color: AppTheme.textPrimary, size: 22),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tax.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                                      const SizedBox(height: 3),
                                      Text('${tax.rate}%', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: taxes.isEmpty
          ? null
          : FloatingActionButton(onPressed: _createTax, backgroundColor: AppTheme.primary, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}
