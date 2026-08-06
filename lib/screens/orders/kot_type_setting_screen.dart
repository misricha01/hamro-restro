import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../../widgets/common/settings_section_tile.dart';
import 'add_kot_type_screen.dart';

const List<String> kOrderActionOptions = ['Confirm Only', 'Confirm & Print Only', 'Confirm as Primary', 'Confirm & Print as Primary'];

class _CustomField {
  String label;
  bool checked;
  _CustomField(this.label, this.checked);
}

/// "KOT Type Setting" reached from Orders' 3-dot Actions menu. "Setting" tab
/// matches the reference's KOT print/behavior config; "Type" tab lists KOT
/// types and reuses [AddKotTypeScreen] to create new ones.
class KotTypeSettingScreen extends StatefulWidget {
  const KotTypeSettingScreen({super.key});

  @override
  State<KotTypeSettingScreen> createState() => _KotTypeSettingScreenState();
}

class _KotTypeSettingScreenState extends State<KotTypeSettingScreen> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  // Header details — fixed fields (not reorderable)
  bool _kotNumber = true;
  bool _table = true;
  bool _time = true;

  // Header details — custom fields the reference lets you drag-reorder
  final List<_CustomField> _customHeaderFields = [
    _CustomField('Order Type', true),
    _CustomField('Order By', true),
    _CustomField('Table Subheading Enabled', true),
  ];

  // Line items — labels are renameable via the pencil icon
  bool _sn = true;
  String _snLabel = 'S.N';
  bool _dishes = true;
  String _dishesLabel = 'Dishes';
  bool _qty = true;
  String _qtyLabel = 'QTY';

  // Footer details — fixed field then reorderable custom fields
  bool _kotRemarksField = true;
  String _kotRemarksLabel = 'KOT Remarks';
  final List<_CustomField> _customFooterFields = [
    _CustomField('Printed By', true),
    _CustomField('Printed At', true),
    _CustomField('Total', true),
  ];

  bool _footerTextEnabled = true;
  final _footerController = TextEditingController(text: 'Thank You!');

  String _orderAction = 'Confirm as Primary';
  String _cancelAction = 'Confirm as Primary';
  String _editAction = 'Confirm as Primary';

  // KOT Print Setting
  final _printCopiesController = TextEditingController(text: '1');
  bool _printAfterCancellation = true;
  bool _printAfterUpdate = true;

  // KOT View
  bool _compactView = false;

  // Dish Remarks
  bool _dishRemarks = true;
  String _dishRemarksLabel = 'Dish Remarks';
  bool _dishRemarksBelowDish = false;

  // Reset KOT Number
  bool _autoResetWithDaybook = false;

  final List<String> _kotTypes = [];

  @override
  void dispose() {
    _tabController.dispose();
    _footerController.dispose();
    _printCopiesController.dispose();
    super.dispose();
  }

  Future<void> _pickAction(String current, ValueChanged<String> onPicked) async {
    final picked = await SimpleListSheet.show(context, title: 'Select Action', items: kOrderActionOptions);
    if (picked != null) onPicked(picked);
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KOT settings saved')));
  }

  Future<void> _addKotType() async {
    final type = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const AddKotTypeScreen()));
    if (type != null) setState(() => _kotTypes.add(type));
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
        title: const Text('KOT Setting', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening KOT preview...'))),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.divider)),
              child: const Text('Preview', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.cancelled,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.cancelled,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.none),
          unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
          tabs: const [Tab(text: 'Setting'), Tab(text: 'Type')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildSettingTab(), _buildTypeTab()],
        ),
      ),
    );
  }

  Widget _buildSettingTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSectionTile(
                title: 'KOT Header Details',
                initiallyExpanded: true,
                children: [
                  SettingsCheckRow(label: 'KOT Number', value: _kotNumber, onChanged: (v) => setState(() => _kotNumber = v)),
                  SettingsCheckRow(label: 'Table', value: _table, onChanged: (v) => setState(() => _table = v)),
                  SettingsCheckRow(label: 'Time', value: _time, onChanged: (v) => setState(() => _time = v)),
                  ReorderableSettingsGroup(
                    onReorder: (oldIndex, newIndex) => setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final field = _customHeaderFields.removeAt(oldIndex);
                      _customHeaderFields.insert(newIndex, field);
                    }),
                    children: [
                      for (int i = 0; i < _customHeaderFields.length; i++)
                        SettingsCheckRow(
                          key: ValueKey('header-field-$i'),
                          label: _customHeaderFields[i].label,
                          value: _customHeaderFields[i].checked,
                          onChanged: (v) => setState(() => _customHeaderFields[i].checked = v),
                          highlighted: true,
                          dragHandle: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_indicator, color: AppTheme.textSecondary, size: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SettingsSectionTile(
                title: 'Line Items Details',
                children: [
                  SettingsCheckRow(label: _snLabel, value: _sn, onChanged: (v) => setState(() => _sn = v), editable: true, highlighted: true, onEdit: (v) => setState(() => _snLabel = v)),
                  SettingsCheckRow(label: _dishesLabel, value: _dishes, onChanged: (v) => setState(() => _dishes = v), editable: true, onEdit: (v) => setState(() => _dishesLabel = v)),
                  SettingsCheckRow(label: _qtyLabel, value: _qty, onChanged: (v) => setState(() => _qty = v), editable: true, onEdit: (v) => setState(() => _qtyLabel = v)),
                ],
              ),
              SettingsSectionTile(
                title: 'KOT Footer Details',
                children: [
                  SettingsCheckRow(label: _kotRemarksLabel, value: _kotRemarksField, onChanged: (v) => setState(() => _kotRemarksField = v), editable: true, onEdit: (v) => setState(() => _kotRemarksLabel = v)),
                  ReorderableSettingsGroup(
                    onReorder: (oldIndex, newIndex) => setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final field = _customFooterFields.removeAt(oldIndex);
                      _customFooterFields.insert(newIndex, field);
                    }),
                    children: [
                      for (int i = 0; i < _customFooterFields.length; i++)
                        SettingsCheckRow(
                          key: ValueKey('footer-field-$i'),
                          label: _customFooterFields[i].label,
                          value: _customFooterFields[i].checked,
                          onChanged: (v) => setState(() => _customFooterFields[i].checked = v),
                          highlighted: true,
                          editable: true,
                          onEdit: (v) => setState(() => _customFooterFields[i].label = v),
                          dragHandle: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_indicator, color: AppTheme.textSecondary, size: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Footer Text', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none))),
                        Switch(value: _footerTextEnabled, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: (v) => setState(() => _footerTextEnabled = v)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppTextField(controller: _footerController, hint: 'Footer text'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Default Action', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 14),
                    const FieldLabel(label: 'Order Action', required: false),
                    const SizedBox(height: 6),
                    SelectField(hint: 'Select', value: _orderAction, onTap: () => _pickAction(_orderAction, (v) => setState(() => _orderAction = v))),
                    const SizedBox(height: 14),
                    const FieldLabel(label: 'Cancel Action', required: false),
                    const SizedBox(height: 6),
                    SelectField(hint: 'Select', value: _cancelAction, onTap: () => _pickAction(_cancelAction, (v) => setState(() => _cancelAction = v))),
                    const SizedBox(height: 14),
                    const FieldLabel(label: 'Edit Action', required: false),
                    const SizedBox(height: 6),
                    SelectField(hint: 'Select', value: _editAction, onTap: () => _pickAction(_editAction, (v) => setState(() => _editAction = v))),
                  ],
                ),
              ),
              SettingsSectionTile(
                title: 'KOT Print Setting',
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Print Copies', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none))),
                      SizedBox(
                        width: 130,
                        child: AppTextField(controller: _printCopiesController, hint: '1', keyboardType: TextInputType.number, suffixIcon: const Padding(padding: EdgeInsets.only(right: 12), child: Center(widthFactor: 1, child: Text('copies', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SettingsCheckRow(label: 'Print updated KOT after Dish Cancellation', value: _printAfterCancellation, onChanged: (v) => setState(() => _printAfterCancellation = v), highlighted: true),
                  SettingsCheckRow(label: 'Print updated KOT after Dish Update', value: _printAfterUpdate, onChanged: (v) => setState(() => _printAfterUpdate = v), highlighted: true),
                ],
              ),
              SettingsSectionTile(
                title: 'KOT View',
                children: [
                  SettingsCheckRow(label: 'Compact View', value: _compactView, onChanged: (v) => setState(() => _compactView = v)),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dish Remarks', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 10),
                    SettingsCheckRow(label: _dishRemarksLabel, value: _dishRemarks, onChanged: (v) => setState(() => _dishRemarks = v), editable: true, highlighted: true, onEdit: (v) => setState(() => _dishRemarksLabel = v)),
                    const SizedBox(height: 4),
                    const Text('Position', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PositionChip(label: 'KOT Footer', selected: !_dishRemarksBelowDish, onTap: () => setState(() => _dishRemarksBelowDish = false)),
                        const SizedBox(width: 10),
                        _PositionChip(label: 'Below Dish', selected: _dishRemarksBelowDish, onTap: () => setState(() => _dishRemarksBelowDish = true)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('The selected option will determine where dish remarks will be displayed.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reset KOT Number', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 2),
                    const Text('Schedule Reset for KOT Numbers', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                      child: Row(
                        children: [
                          const Expanded(child: Text('Automatically Reset with Daybook', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none))),
                          Switch(value: _autoResetWithDaybook, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: (v) => setState(() => _autoResetWithDaybook = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, height: 1.4, decoration: TextDecoration.none),
                          children: [
                            TextSpan(text: 'Note : ', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                            TextSpan(text: 'KOT numbers can be reset manually or automatically based on the Daybook close date, depending on your selection. Resetting KOT Number will result in the upcoming KOT number start from 1. To manually reset KOT numbers, please click below button.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KOT number reset'))),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Reset Manually', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                  ],
                ),
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
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTab() {
    if (_kotTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.layers_outlined, size: 72, color: AppTheme.accent.withValues(alpha: 0.35)),
              const SizedBox(height: 16),
              const Text('No KOT Types yet', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
              const SizedBox(height: 8),
              const Text('Create KOT types like Kitchen or Bar to route items to the right printer.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _addKotType,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add KOT Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: _kotTypes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, color: AppTheme.accent),
                const SizedBox(width: 12),
                Expanded(child: Text(_kotTypes[index], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(backgroundColor: AppTheme.primary, onPressed: _addKotType, child: const Icon(Icons.add, color: Colors.white)),
        ),
      ],
    );
  }
}

class _PositionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PositionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
      ),
    );
  }
}
