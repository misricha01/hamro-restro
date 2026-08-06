import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DeliveryPlatform {
  final String name;
  final IconData icon;
  final Color iconBackground;

  DeliveryPlatform({required this.name, required this.icon, required this.iconBackground});
}

class SelectDeliveryPlatformScreen extends StatefulWidget {
  const SelectDeliveryPlatformScreen({super.key});

  @override
  State<SelectDeliveryPlatformScreen> createState() => _SelectDeliveryPlatformScreenState();
}

class _SelectDeliveryPlatformScreenState extends State<SelectDeliveryPlatformScreen> {
  String? _selected;
  final TextEditingController _searchController = TextEditingController();

  final List<DeliveryPlatform> _platforms = [
    DeliveryPlatform(name: 'Direct Order', icon: Icons.call, iconBackground: Colors.black),
    DeliveryPlatform(name: 'Website', icon: Icons.language, iconBackground: AppTheme.accent),
  ];

  List<DeliveryPlatform> get _filtered {
    if (_searchController.text.isEmpty) return _platforms;
    return _platforms
        .where((p) => p.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Select Delivery Platform',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                    onPressed: () => setState(() => _searchController.clear()),
                  )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final platform = _filtered[index];
                final isSelected = _selected == platform.name;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selected = platform.name);
                    Navigator.pop(context);
                    // TODO: proceed with selected platform
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: platform.iconBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(platform.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            platform.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Total Delivery Platform : ${_platforms.length}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, decoration: TextDecoration.none),
                children: [
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Set a default ',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextSpan(
                    text: 'Delivery Platform',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                  TextSpan(
                    text: ' so you do not have to select one every time.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}