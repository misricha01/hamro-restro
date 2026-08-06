import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/static/country_data.dart';
import '../../data/static/timezone_data.dart';

/// "Country" picker bottom sheet for Restaurant Details — searches the full
/// [kCountries] list and returns the picked country name.
class CountryPickerSheet extends StatefulWidget {
  final String? selected;
  const CountryPickerSheet({super.key, this.selected});

  static Future<String?> show(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerSheet(selected: selected),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final _searchController = TextEditingController();

  List<CountryOption> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return kCountries;
    return kCountries.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final items = _filtered;
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
                      const Text('Country', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search country...',
                            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : GestureDetector(
                                    onTap: () => setState(() => _searchController.clear()),
                                    child: const Icon(Icons.close, color: AppTheme.cancelled, size: 20),
                                  ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(
                                child: Text('No country found', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: items.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final selected = item.name == widget.selected;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.pop(context, item.name),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                      decoration: BoxDecoration(
                                        color: AppTheme.card,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(item.flag, style: const TextStyle(fontSize: 20)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(item.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                          ),
                                          if (selected) const Icon(Icons.check, color: AppTheme.primary, size: 20),
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

/// "Restaurant Time Zone" picker bottom sheet for Restaurant Details —
/// searches the full [kAllTimezones] list (grouped by region under a small
/// header) and returns the picked IANA id (e.g. "Asia/Kathmandu").
class TimezonePickerSheet extends StatefulWidget {
  final String? selected;
  const TimezonePickerSheet({super.key, this.selected});

  static Future<String?> show(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimezonePickerSheet(selected: selected),
    );
  }

  @override
  State<TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<TimezonePickerSheet> {
  final _searchController = TextEditingController();

  List<TimezoneOption> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return kAllTimezones;
    return kAllTimezones.where((z) => z.city.toLowerCase().contains(q) || z.id.toLowerCase().contains(q) || z.region.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final items = _filtered;
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
                      const Text('Restaurant Time Zone', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : GestureDetector(
                                    onTap: () => setState(() => _searchController.clear()),
                                    child: const Icon(Icons.close, color: AppTheme.cancelled, size: 20),
                                  ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(
                                child: Text('No time zone found', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final showRegionHeader = index == 0 || items[index - 1].region != item.region;
                                  final selected = item.id == widget.selected;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (showRegionHeader)
                                          Padding(
                                            padding: EdgeInsets.only(top: index == 0 ? 0 : 6, bottom: 8),
                                            child: Text(
                                              item.region.toUpperCase(),
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.6, decoration: TextDecoration.none),
                                            ),
                                          ),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () => Navigator.pop(context, item.id),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.card,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 38,
                                                  height: 38,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
                                                  child: Text(
                                                    item.city.length >= 2 ? item.city.substring(0, 2).toUpperCase() : item.city.toUpperCase(),
                                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(item.city, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                                      const SizedBox(height: 2),
                                                      Text(item.id, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                                                    ],
                                                  ),
                                                ),
                                                if (selected) const Icon(Icons.check, color: AppTheme.primary, size: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
