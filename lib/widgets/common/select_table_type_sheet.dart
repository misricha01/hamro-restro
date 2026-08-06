import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// "Select Table Type" picker opened from [AddTableScreen]'s Table Type
/// field. Mirrors [SelectStockGroupSheet] / [SelectUnitSheet]'s light
/// search + list + create-button layout.
class SelectTableTypeSheet extends StatefulWidget {
  final ValueChanged<String> onSelected;

  const SelectTableTypeSheet({super.key, required this.onSelected});

  static Future<void> show(BuildContext context, {required ValueChanged<String> onSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectTableTypeSheet(onSelected: onSelected),
    );
  }

  @override
  State<SelectTableTypeSheet> createState() => _SelectTableTypeSheetState();
}

class _SelectTableTypeSheetState extends State<SelectTableTypeSheet> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _types = ['Cabin', 'Room', 'Sofa', 'Table'];

  List<String> get _filtered {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _types;
    return _types.where((t) => t.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      'Select Table Type',
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final type = _filtered[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        widget.onSelected(type);
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
                          type,
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
                'Total Table Type : ${_types.length}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create Table Type coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Create Table Type',
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
