import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/area/area_model.dart';
import '../../providers/area_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../screens/manage/create_space_screen.dart';

/// "Select Space" picker opened from [AddTableScreen]'s Space field. Reads
/// its list live from [AreaProvider] (shared app-wide, see main.dart) so it
/// always reflects the same spaces shown on [ManageSpaceScreen]. Shows the
/// same empty state until a space is added via [CreateSpaceScreen], then
/// behaves like the other light "select_X_sheet" pickers (search + list).
class SelectSpaceSheet extends StatefulWidget {
  final ValueChanged<Area> onSelected;

  const SelectSpaceSheet({super.key, required this.onSelected});

  static Future<void> show(BuildContext context, {required ValueChanged<Area> onSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectSpaceSheet(onSelected: onSelected),
    );
  }

  @override
  State<SelectSpaceSheet> createState() => _SelectSpaceSheetState();
}

class _SelectSpaceSheetState extends State<SelectSpaceSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AreaProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchAreas());
    }
  }

  List<Area> _filtered(List<Area> areas) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return areas;
    return areas.where((s) => s.areaName.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createSpace() async {
    final result = await Navigator.push<Area>(context, MaterialPageRoute(builder: (context) => const CreateSpaceScreen()));
    if (result == null || !mounted) return;
    widget.onSelected(result);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final areaProvider = context.watch<AreaProvider>();

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
                      'Select Space',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(areaProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AreaProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _buildError(provider.errorMessage ?? 'Something went wrong.');
      case LoadStatus.loaded:
        return provider.areas.isEmpty ? _buildEmptyState() : _buildList(provider.areas);
    }
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.read<AreaProvider>().fetchAreas(),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
              child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
            child: const Icon(Icons.layers_outlined, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Space', style: TextStyle(color: AppTheme.accent)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No Space found. Needs to create the Space!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _createSpace,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Create New Space',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Learn More',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Area> areas) {
    final filtered = _filtered(areas);
    return Column(
      children: [
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
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final space = filtered[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    widget.onSelected(space);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      space.areaName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Total Space : ${areas.length}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _createSpace,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Create New Space',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
