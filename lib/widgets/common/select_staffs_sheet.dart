import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StaffOption {
  final String name;
  final String username;
  const StaffOption({required this.name, required this.username});
}

/// "Select Staffs" picker opened from the Sales & Purchase filter row's
/// "Entry By" field. Mirrors [SelectSpaceSheet]/[SelectRoleSheet]'s light
/// search + checkbox-list layout.
class SelectStaffsSheet extends StatefulWidget {
  final List<StaffOption> staffs;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onApply;

  const SelectStaffsSheet({super.key, required this.staffs, this.initialSelected = const [], required this.onApply});

  static Future<void> show(
    BuildContext context, {
    required List<StaffOption> staffs,
    List<String> initialSelected = const [],
    required ValueChanged<List<String>> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectStaffsSheet(staffs: staffs, initialSelected: initialSelected, onApply: onApply),
    );
  }

  @override
  State<SelectStaffsSheet> createState() => _SelectStaffsSheetState();
}

class _SelectStaffsSheetState extends State<SelectStaffsSheet> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffOption> get _filtered {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return widget.staffs;
    return widget.staffs.where((s) => s.name.toLowerCase().contains(query) || s.username.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Staffs',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(decoration: TextDecoration.none),
                decoration: InputDecoration(
                  hintText: 'Search here',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _searchController.clear()),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final staff = _filtered[index];
                  final checked = _selected.contains(staff.username);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => checked ? _selected.remove(staff.username) : _selected.add(staff.username)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                staff.name.trim().isEmpty
                                    ? '?'
                                    : staff.name.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase(),
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                                  Text(staff.username, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: checked,
                              activeColor: AppTheme.primary,
                              onChanged: (v) => setState(() => (v ?? false) ? _selected.add(staff.username) : _selected.remove(staff.username)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Total Staffs : ${widget.staffs.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selected.toList());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
