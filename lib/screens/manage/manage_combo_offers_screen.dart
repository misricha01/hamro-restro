import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/combo_offer/combo_offer_model.dart';
import '../../providers/combo_offer_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/manage_list_controls.dart';
import '../create_dish/add_combo_screen.dart' show AddComboScreen;

/// Combo Offer list for the Manage screen, reached from the Menu overview's
/// "Combo Offer" row. Sourced live from [ComboOfferProvider] (backend:
/// `/api/combo-offer`).
class ManageComboOffersScreen extends StatefulWidget {
  const ManageComboOffersScreen({super.key});

  @override
  State<ManageComboOffersScreen> createState() => _ManageComboOffersScreenState();
}

class _ManageComboOffersScreenState extends State<ManageComboOffersScreen> {
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ComboOfferProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchComboOffers());
    }
  }

  List<ComboOffer> _filtered(List<ComboOffer> offers) {
    if (_searchController.text.isEmpty) return offers;
    final q = _searchController.text.toLowerCase();
    return offers.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchController.clear();
    });
  }

  Future<void> _createCombo() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddComboScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComboOfferProvider>();

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
          'Combo Offer',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              ManageSearchField(
                controller: _searchController,
                onClose: _toggleSearch,
                onChanged: (_) => setState(() {}),
              ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ComboOfferProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => provider.fetchComboOffers(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filtered(provider.offers);
        return Column(
          children: [
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(onCreate: _createCombo)
                  : RefreshIndicator(
                      color: AppTheme.accent,
                      onRefresh: () => provider.fetchComboOffers(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _ComboCard(combo: filtered[index]),
                      ),
                    ),
            ),
            if (filtered.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Total Combo Offer : ${provider.offers.length}',
                  style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _createCombo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Create New Combo Offer',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }
}

class _ComboCard extends StatelessWidget {
  final ComboOffer combo;
  const _ComboCard({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.set_meal_outlined, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  combo.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                ),
                Text(
                  '${combo.dishIds.length} item(s)',
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${combo.offerPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accent, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
            child: const Icon(Icons.set_meal_outlined, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Combo Offer', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No Combo Offer found. Needs to create the Combo Offer!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Create New Combo Offer',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _InfoRow(
            icon: Icons.crop_free,
            title: '1. Own QR Code',
            description: 'By creating a table, the Hamro Restro system will generate a QR code from which customers may place orders.',
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.smartphone_outlined,
            title: '2. Proper Order tracking',
            description: 'Orders received from customers were recorded in a single table. All associated orders will be handled.',
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.description_outlined,
            title: '3. Manual KOT',
            description: 'Its ok to use paper KOT, you can make entry of that from any device in Hamro Restro.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _InfoRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: TextDecoration.none)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
            ],
          ),
        ),
      ],
    );
  }
}
