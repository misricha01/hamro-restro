import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../data/models/stock/stock_model.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/staff_provider.dart';
import '../../widgets/common/finance_form_fields.dart' show AppDateField, SelectField;
import '../../widgets/common/select_stock_group_sheet.dart';
import '../../widgets/common/select_stock_sheet.dart';

/// Filter values collected by [StockHistoryFilterSheet] and applied by
/// [StockHistoryScreen]. `startDate`/`endDate`/`stockId`/`stockGroupId`/
/// `staffId` are sent to `GET /api/stock/history`; `type` has no matching
/// query param on this backend, so it's applied client-side against the
/// already-fetched list instead.
class StockHistoryFilter {
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final Stock? stock;
  final StockGroup? stockGroup;
  final StaffMember? staff;

  const StockHistoryFilter({
    required this.startDate,
    required this.endDate,
    required this.type,
    this.stock,
    this.stockGroup,
    this.staff,
  });
}

/// "Filter" sheet opened from [StockHistoryScreen]'s Filter button, matching
/// the reference design's Date presets/range, Sales Staff, Type, Stock Item
/// and Stock Group filters with Discard / Apply Filter actions.
class StockHistoryFilterSheet extends StatefulWidget {
  final StockHistoryFilter? initial;
  const StockHistoryFilterSheet({super.key, this.initial});

  static Future<StockHistoryFilter?> show(BuildContext context, {StockHistoryFilter? initial}) {
    return showModalBottomSheet<StockHistoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockHistoryFilterSheet(initial: initial),
    );
  }

  @override
  State<StockHistoryFilterSheet> createState() => _StockHistoryFilterSheetState();
}

class _StockHistoryFilterSheetState extends State<StockHistoryFilterSheet> {
  static const _datePresets = ['Today', 'This Week', 'This Month', 'Last Week', 'Last Month', 'This Year', 'Life Time'];
  static const _types = ['All', 'Opening', 'Manual', 'Sales', 'Sales Return', 'Purchase', 'Purchase Return'];

  String _datePreset = 'Life Time';
  late String _type = widget.initial?.type ?? 'All';
  StaffMember? _staff;
  Stock? _stock;
  StockGroup? _stockGroup;

  late DateTime _fromDate = widget.initial?.startDate ?? DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  late DateTime _toDate = widget.initial?.endDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _staff = widget.initial?.staff;
    _stock = widget.initial?.stock;
    _stockGroup = widget.initial?.stockGroup;
    final staffProvider = context.read<StaffProvider>();
    if (staffProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => staffProvider.fetchStaff());
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromDate = result;
        } else {
          _toDate = result;
        }
      });
    }
  }

  Future<void> _pickSalesStaff() async {
    final result = await _SelectSalesStaffSheet.show(context);
    if (result != null) setState(() => _staff = result);
  }

  Future<void> _pickStockItem() async {
    final result = await SelectStockSheet.show(context, title: 'Select Stock Item');
    if (result != null) setState(() => _stock = result);
  }

  Future<void> _pickStockGroup() async {
    await SelectStockGroupSheet.show(context, onSelected: (group) => setState(() => _stockGroup = group));
  }

  String get _dateRangeLabel {
    String fmt(DateTime d) => '${_month(d.month)} ${d.day}';
    return '${fmt(_fromDate)} - ${fmt(_toDate)}';
  }

  static String _month(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

  void _apply() {
    Navigator.pop(
      context,
      StockHistoryFilter(startDate: _fromDate, endDate: _toDate, type: _type, stock: _stock, stockGroup: _stockGroup, staff: _staff),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                                const Spacer(),
                                Text(_dateRangeLabel, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _datePresets.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final preset = _datePresets[index];
                                  return _FilterChip(label: preset, selected: _datePreset == preset, onTap: () => setState(() => _datePreset = preset));
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('From', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                                      const SizedBox(height: 8),
                                      _RedDateField(date: _fromDate, onTap: () => _pickDate(isFrom: true)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('To', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                                      const SizedBox(height: 8),
                                      _RedDateField(date: _toDate, onTap: () => _pickDate(isFrom: false)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            const Text('Sales Staff', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                            const SizedBox(height: 8),
                            SelectField(hint: 'Select Sales Staff', value: _staff?.fullname, onTap: _pickSalesStaff),
                            const SizedBox(height: 20),

                            const Text('Type', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                for (int i = 0; i < _types.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  _FilterChip(label: _types[i], selected: _type == _types[i], onTap: () => setState(() => _type = _types[i]), fullWidth: true),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),

                            const Text('Stock Item', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                            const SizedBox(height: 8),
                            SelectField(hint: 'Select Stock Item', value: _stock?.itemName, onTap: _pickStockItem),
                            const SizedBox(height: 20),

                            const Text('Stock Group', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                            const SizedBox(height: 8),
                            SelectField(hint: 'Select Stock Group', value: _stockGroup?.groupName, onTap: _pickStockGroup),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24, color: AppTheme.divider),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: const Text('Discard', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _apply,
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text('Apply Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: fullWidth ? double.infinity : null,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cancelled.withValues(alpha: 0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? AppTheme.cancelled : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

class _RedDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _RedDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.cancelled)),
        child: Row(
          children: [
            Expanded(child: Text(AppDateField.format(date), style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
            const Icon(Icons.calendar_today_outlined, color: AppTheme.cancelled, size: 18),
          ],
        ),
      ),
    );
  }
}

/// "Select Sales Staff" sheet, sourced live from [StaffProvider] (backend:
/// `GET /api/user/all`) — mirrors [SelectStockSheet]'s search + list pattern.
class _SelectSalesStaffSheet extends StatefulWidget {
  const _SelectSalesStaffSheet();

  static Future<StaffMember?> show(BuildContext context) {
    return showModalBottomSheet<StaffMember>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SelectSalesStaffSheet(),
    );
  }

  @override
  State<_SelectSalesStaffSheet> createState() => _SelectSalesStaffSheetState();
}

class _SelectSalesStaffSheetState extends State<_SelectSalesStaffSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<StaffMember> _filtered(List<StaffMember> staff) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return staff;
    return staff.where((s) => s.fullname.toLowerCase().contains(query) || s.email.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    final staff = _filtered(provider.staff);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Sales Staff', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: provider.status == LoadStatus.loading || provider.status == LoadStatus.idle
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: staff.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final member = staff[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context, member),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                          child: Text(
                                            member.fullname.trim().isEmpty
                                                ? '?'
                                                : member.fullname.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase(),
                                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(member.fullname, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                                              Text(member.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text('Total Staff : ${provider.staff.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
