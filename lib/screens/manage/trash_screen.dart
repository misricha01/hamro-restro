import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_empty_state.dart';

/// "Trash" screen reached from Manage > Setting > Dangerous Area: deleted
/// events grouped under "All" / "Void Invoice" tabs, matching the reference.
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Trash', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list, color: AppTheme.textPrimary), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
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
          tabs: const [Tab(text: 'All'), Tab(text: 'Void Invoice')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SettingEmptyState(
            title: 'Trash',
            subtitle: 'No trash Found. Delete items to see them here.',
            showLearnMore: false,
          ),
          SettingEmptyState(
            title: 'Trash',
            subtitle: 'No trash Found. Delete items to see them here.',
            showLearnMore: false,
          ),
        ],
      ),
    );
  }
}
