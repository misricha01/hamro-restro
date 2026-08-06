import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/unit/unit_model.dart';
import '../../providers/unit_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../screens/inventory/add_measuring_unit_screen.dart';

/// Picker for a [Unit], sourced live from [UnitProvider] (backend:
/// `/api/unit`) — falls back to [kFallbackUnits] the same way the dish
/// creation unit picker does when the list is empty/unavailable.
class SelectUnitSheet extends StatefulWidget {
  final ValueChanged<Unit> onSelected;

  const SelectUnitSheet({super.key, required this.onSelected});

  static Future<void> show(BuildContext context, {required ValueChanged<Unit> onSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectUnitSheet(onSelected: onSelected),
    );
  }

  @override
  State<SelectUnitSheet> createState() => _SelectUnitSheetState();
}

class _SelectUnitSheetState extends State<SelectUnitSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<UnitProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchUnits());
    }
  }

  List<Unit> _filtered(List<Unit> units) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return units;
    return units.where((u) => u.name.toLowerCase().contains(query) || (u.description ?? '').toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UnitProvider>();
    final showingFallback = provider.useFallback || (provider.status == LoadStatus.loaded && provider.units.isEmpty);
    final units = _filtered(showingFallback ? kFallbackUnits : provider.units);

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
                      'Select Unit',
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
              child: provider.status == LoadStatus.loading || provider.status == LoadStatus.idle
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        final unit = units[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              widget.onSelected(unit);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.divider),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    unit.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const Spacer(),
                                  if ((unit.description ?? '').isNotEmpty)
                                    Text(
                                      unit.description!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                        decoration: TextDecoration.none,
                                      ),
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
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final unit = await Navigator.push<Unit>(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMeasuringUnitScreen()),
                    );
                    if (unit != null && context.mounted) {
                      widget.onSelected(unit);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Create Measuring Unit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
