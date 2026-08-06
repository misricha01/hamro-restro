import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/department.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/setting_empty_state.dart';
import 'create_department_screen.dart';

/// "Department" screen reached from Manage > Setting > General Setting:
/// manage sub-menus and assign printers per department. Shows the empty
/// state until the first department is created, matching the reference.
class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  bool _selectMode = false;

  final List<Department> _departments = [];

  List<Department> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _departments;
    return _departments.where((d) => d.name.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createDepartment() async {
    final department = await Navigator.push<Department>(context, MaterialPageRoute(builder: (context) => const CreateDepartmentScreen()));
    if (department != null) setState(() => _departments.add(department));
  }

  Future<void> _editDepartment(int index) async {
    final updated = await Navigator.push<Department>(
      context,
      MaterialPageRoute(builder: (context) => CreateDepartmentScreen(initial: _departments[index])),
    );
    if (updated != null) setState(() => _departments[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final departments = _filtered;
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
          'Department',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searching, onTap: () => setState(() => _searching = !_searching)),
          PopupMenuButton<String>(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
            onSelected: (value) {
              if (value == 'select') {
                setState(() => _selectMode = !_selectMode);
              } else if (value == 'help') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening help article...')));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'select',
                child: Row(
                  children: [
                    Icon(_selectMode ? Icons.check_box : Icons.check_box_outline_blank, color: AppTheme.textPrimary, size: 20),
                    const SizedBox(width: 10),
                    const Text('Select Department', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: AppTheme.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text('Help', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.more_horiz, color: AppTheme.textPrimary),
            ),
          ),
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
              child: departments.isEmpty
                  ? SettingEmptyState(
                      title: 'Department',
                      subtitle: 'No Department found. Needs to create the Department!',
                      actionLabel: 'Create New Department',
                      onAction: _createDepartment,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
                      itemCount: departments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _editDepartment(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                            child: Row(
                              children: [
                                if (_selectMode) ...[
                                  const Icon(Icons.check_box_outline_blank, color: AppTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                ],
                                const Icon(Icons.folder_outlined, color: AppTheme.textPrimary, size: 22),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(department.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                                      if (department.description.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(department.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                                      ],
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
      floatingActionButton: departments.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _createDepartment,
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
