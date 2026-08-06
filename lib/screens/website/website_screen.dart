import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/website_models.dart';
import '../../widgets/common/toggle_card.dart';
import '../create_dish/add_dish_screen.dart' show ImageSourceSheet;
import 'custom_link_sheet.dart';
import 'edit_details_screen.dart';
import 'social_links_sheet.dart';

/// "Website" module screen, reached from the Manage screen's Website row.
/// Mirrors the Delivery Service screen's tabbed-details conventions
/// (AppTheme colors, card styling, share/link cards) across three tabs:
/// Restro Link, Menu Images and Appearance.
class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({super.key});

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  int _tabIndex = 0;

  // --- Restro Link tab state ---------------------------------------------
  static const String _restroUrl = 'https://restrox.com/restrox226';
  bool _deliveryServiceOn = true;
  bool _shareMyMenuOn = true;
  bool _phoneNumberOn = true;
  final String _address = 'M8MM+CM7, Shankhamul Marg, Kathmandu 44600, Nepal';
  List<SocialLink> _socialLinks = [];
  final List<CustomLink> _usefulLinks = [];

  // --- Menu Images tab state ----------------------------------------------
  static const String _menuUrl = 'https://restrox226.restro.link/en/menu';
  final List<String> _menuImages = [];

  // --- Appearance tab state ------------------------------------------------
  String? _logoImageSource;
  final _headingController = TextEditingController(text: 'Hamro Restro');
  final _bioController = TextEditingController();
  final _footerController = TextEditingController();
  WebsiteLayout _layout = WebsiteLayout.grid;
  int _paletteIndex = 0;
  Color? _customBackground;
  Color? _customCard;
  Color? _customCardText;
  Color? _customText;

  static final List<ColorPalette> _palettes = [
    const ColorPalette(name: 'Light', subtitle: 'Black and White', colors: [Color(0xFF111111), Color(0xFF9E9E9E), Color(0xFF1A1A1A), Color(0xFFFFFFFF)]),
    const ColorPalette(name: 'Dark Vibes', subtitle: 'Dark Night', colors: [Color(0xFFE0E0E0), Color(0xFF2B2B2B), Color(0xFFFFFFFF), Color(0xFF000000)]),
    const ColorPalette(name: 'Rustic Charm', subtitle: 'Warm & Homely', colors: [Color(0xFF3E8FD0), Color(0xFFA9C9E8), Color(0xFF1B4F8C), Color(0xFFF5EEF7)]),
    const ColorPalette(name: 'Green Gourmet', subtitle: 'Fresh & Organic', colors: [Color(0xFF3E8FD0), Color(0xFFBEE0F5), Color(0xFF2E7BC4), Color(0xFFFFFFFF)]),
    const ColorPalette(name: 'Elegant Evenings', subtitle: 'Luxe & Romantic', colors: [Color(0xFF5B4436), Color(0xFFE4C6A8), Color(0xFFA85C40), Color(0xFFFFFFFF)]),
    const ColorPalette(name: 'Midnight Feast', subtitle: 'Luxe & Moody', colors: [Color(0xFF33323F), Color(0xFFC9BFF0), Color(0xFF5B4FE0), Color(0xFFFFFFFF)]),
  ];

  @override
  void dispose() {
    _headingController.dispose();
    _bioController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------
  Future<void> _addSocialLinks() async {
    final selected = await SelectSocialLinksSheet.show(context, initial: _socialLinks.map((e) => e.platform).toSet());
    if (!mounted || selected == null || selected.isEmpty) return;
    final result = await SocialLinkUrlsSheet.show(context, platforms: selected.toList(), existing: _socialLinks);
    if (result != null) setState(() => _socialLinks = result);
  }

  void _removeSocialLink(SocialPlatform platform) {
    setState(() => _socialLinks = _socialLinks.where((e) => e.platform != platform).toList());
  }

  Future<void> _addUsefulLink() async {
    final result = await AddCustomLinkSheet.show(context);
    if (result != null) setState(() => _usefulLinks.add(result));
  }

  void _removeUsefulLink(CustomLink link) {
    setState(() => _usefulLinks.remove(link));
  }

  Future<void> _openEditDetails() async {
    await Navigator.push<WebsiteDetails>(context, MaterialPageRoute(builder: (context) => const EditDetailsScreen()));
  }

  Future<void> _pickMenuImage() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _menuImages.add(result));
  }

  Future<void> _pickLogo() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _logoImageSource = result);
  }

  Future<void> _pickCustomColor(ValueChanged<Color> onPicked) async {
    final result = await _ColorPickerDialog.show(context);
    if (result != null) onPicked(result);
  }

  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  void _openLink(String url) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening link...')));
  }

  void _shareQr(String label, String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareQrSheet(label: label, url: url),
    );
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
        title: const Text(
          'Website',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _WebsiteTabs(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
            const Divider(height: 1, color: AppTheme.divider),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildRestroLinkTab(),
                  _buildMenuImagesTab(),
                  _buildAppearanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Restro Link tab
  // ------------------------------------------------------------------
  Widget _buildRestroLinkTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ShareLinkCard(
          title: 'Share Restro Link',
          url: _restroUrl,
          onCopy: () => _copyLink(_restroUrl),
          onOpenLink: () => _openLink(_restroUrl),
          onCustomDomain: _openEditDetails,
          onShareQr: () => _shareQr('Restro Link', _restroUrl),
        ),
        const SizedBox(height: 20),

        const _SectionLabel(label: 'Services'),
        const SizedBox(height: 10),
        ToggleCard(
          title: 'Delivery Service',
          description: 'Would you like to offer delivery to your customers?',
          value: _deliveryServiceOn,
          onChanged: (v) => setState(() => _deliveryServiceOn = v),
        ),
        const SizedBox(height: 12),
        ToggleCard(
          title: 'Share My Menu',
          description: 'Would you like to share your menu?',
          value: _shareMyMenuOn,
          onChanged: (v) => setState(() => _shareMyMenuOn = v),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            const Expanded(child: _SectionLabel(label: 'Restaurant Details')),
            InkWell(
              onTap: _openEditDetails,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit_outlined, color: AppTheme.accent, size: 20)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToggleCard(
          title: 'Phone number',
          description: 'Would you like to enable phone number for customers?',
          value: _phoneNumberOn,
          onChanged: (v) => setState(() => _phoneNumberOn = v),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Expanded(child: Text(_address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
                    const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Map picker coming soon'))),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                child: const Icon(Icons.map_outlined, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _LinksSection(
          label: 'Social Links',
          onAddLinks: _addSocialLinks,
          child: _socialLinks.isEmpty
              ? null
              : Column(
                  children: [
                    for (final link in _socialLinks) ...[
                      _SocialLinkRow(link: link, onRemove: () => _removeSocialLink(link.platform)),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 24),

        _LinksSection(
          label: 'Useful Links',
          onAddLinks: _addUsefulLink,
          child: _usefulLinks.isEmpty
              ? null
              : Column(
                  children: [
                    for (final link in _usefulLinks) ...[
                      _UsefulLinkRow(link: link, onRemove: () => _removeUsefulLink(link)),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Menu Images tab
  // ------------------------------------------------------------------
  Widget _buildMenuImagesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ShareLinkCard(
          title: 'Share Menu Link',
          url: _menuUrl,
          onCopy: () => _copyLink(_menuUrl),
          onOpenLink: () => _openLink(_menuUrl),
          onCustomDomain: _openEditDetails,
          onShareQr: () => _shareQr('Menu Link', _menuUrl),
        ),
        const SizedBox(height: 20),

        const Text('Upload Menu', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 4),
        const Text('Upload and showcase your menu design with images.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
        const SizedBox(height: 12),
        _UploadBox(label: 'Tap here to select or upload photos', onTap: _pickMenuImage),
        const SizedBox(height: 24),

        const Text('Preview', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 4),
        const Text('Check your uploaded file and sort them accordingly.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
        const SizedBox(height: 12),
        if (_menuImages.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuImages.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _menuImages.removeAt(oldIndex);
                _menuImages.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey('menu-image-$index-${_menuImages[index]}'),
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, color: AppTheme.textSecondary),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.image_outlined, color: AppTheme.textSecondary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Menu image ${index + 1}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                      InkWell(
                        onTap: () => setState(() => _menuImages.removeAt(index)),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppTheme.cancelled, size: 18)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Appearance tab
  // ------------------------------------------------------------------
  Widget _buildAppearanceTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text('Restaurant Logo', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 10),
        _UploadBox(
          label: _logoImageSource == null ? 'Tap here to select or upload photos' : 'Selected via $_logoImageSource',
          onTap: _pickLogo,
        ),
        const SizedBox(height: 20),

        RichText(
          text: const TextSpan(
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
            children: [TextSpan(text: 'Heading'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
          ),
        ),
        const SizedBox(height: 8),
        _AppTextField(controller: _headingController, hint: 'Enter a catchy heading for your menu page.'),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
                  children: [TextSpan(text: 'Bio'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
                ),
              ),
            ),
            Text('${_bioController.text.length} / 200', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
          ],
        ),
        const SizedBox(height: 8),
        _AppTextField(controller: _bioController, hint: 'Enter a catchy heading for your menu page.', maxLines: 4, maxLength: 200, onChanged: (_) => setState(() {})),
        const SizedBox(height: 20),

        const Text('Footer', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 8),
        _AppTextField(controller: _footerController, hint: 'Enter a custom footer message for you menu.'),
        const SizedBox(height: 24),

        const Text('Layouts', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _LayoutCard(layout: WebsiteLayout.grid, selected: _layout == WebsiteLayout.grid, onTap: () => setState(() => _layout = WebsiteLayout.grid))),
            const SizedBox(width: 14),
            Expanded(child: _LayoutCard(layout: WebsiteLayout.list, selected: _layout == WebsiteLayout.list, onTap: () => setState(() => _layout = WebsiteLayout.list))),
          ],
        ),
        const SizedBox(height: 24),

        const Text('Color Palettes', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 12),
        for (int i = 0; i < _palettes.length; i++) ...[
          _PaletteCard(palette: _palettes[i], selected: _paletteIndex == i, onTap: () => setState(() => _paletteIndex = i)),
          const SizedBox(height: 12),
        ],

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Customize Your Theme', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none))),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Choose up to three colors to customize your restaurant's theme.",
                        style: TextStyle(color: AppTheme.accent, fontSize: 12.5, decoration: TextDecoration.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _ColorSwatchField(label: 'Background', color: _customBackground, onTap: () => _pickCustomColor((c) => setState(() => _customBackground = c)))),
                  const SizedBox(width: 14),
                  Expanded(child: _ColorSwatchField(label: 'Card', color: _customCard, onTap: () => _pickCustomColor((c) => setState(() => _customCard = c)))),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _ColorSwatchField(label: 'Card Text', color: _customCardText, onTap: () => _pickCustomColor((c) => setState(() => _customCardText = c)))),
                  const SizedBox(width: 14),
                  Expanded(child: _ColorSwatchField(label: 'Text', color: _customText, onTap: () => _pickCustomColor((c) => setState(() => _customText = c)))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// Tabs
// ==========================================================================

class _WebsiteTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _WebsiteTabs({required this.index, required this.onChanged});

  static const _labels = ['Restro Link', 'Menu Images', 'Appearance'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++) ...[
            _tab(i),
            if (i != _labels.length - 1) const SizedBox(width: 24),
          ],
        ],
      ),
    );
  }

  Widget _tab(int i) {
    final selected = index == i;
    return GestureDetector(
      onTap: () => onChanged(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _labels[i],
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 2.5, width: _labels[i].length * 7.5, color: selected ? AppTheme.primary : Colors.transparent),
        ],
      ),
    );
  }
}

// ==========================================================================
// Shared small widgets
// ==========================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none));
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _UploadBox({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          ],
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _AppTextField({required this.controller, required this.hint, this.maxLines = 1, this.maxLength, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        counterText: '',
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

// ==========================================================================
// Restro Link / Menu Images tab widgets
// ==========================================================================

class _ShareLinkCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onCopy;
  final VoidCallback onOpenLink;
  final VoidCallback onCustomDomain;
  final VoidCallback onShareQr;

  const _ShareLinkCard({
    required this.title,
    required this.url,
    required this.onCopy,
    required this.onOpenLink,
    required this.onCustomDomain,
    required this.onShareQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.accent, fontSize: 13, decoration: TextDecoration.none)),
                      ),
                      InkWell(onTap: onCopy, borderRadius: BorderRadius.circular(6), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.copy_outlined, color: AppTheme.textSecondary, size: 17))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onOpenLink,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                  child: const Text('Open Link', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onCustomDomain,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Get your own custom domain', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onShareQr,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_2_rounded, color: AppTheme.textPrimary, size: 18),
                      SizedBox(width: 6),
                      Text('Share QR', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareQrSheet extends StatelessWidget {
  final String label;
  final String url;
  const _ShareQrSheet({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle), child: const Icon(Icons.close, color: AppTheme.accent, size: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.textPrimary, size: 160),
              ),
              const SizedBox(height: 16),
              Text(url, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download coming soon'))),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Download QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinksSection extends StatelessWidget {
  final String label;
  final VoidCallback onAddLinks;
  final Widget? child;

  const _LinksSection({required this.label, required this.onAddLinks, this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none))),
            InkWell(
              onTap: onAddLinks,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppTheme.textPrimary, size: 16),
                    SizedBox(width: 4),
                    Text('Add Links', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (child != null) ...[const SizedBox(height: 12), child!],
      ],
    );
  }
}

class _SocialLinkRow extends StatelessWidget {
  final SocialLink link;
  final VoidCallback onRemove;
  const _SocialLinkRow({required this.link, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: link.platform.brandColor, shape: BoxShape.circle),
            child: Icon(link.platform.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.platform.label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                Text(link.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
              ],
            ),
          ),
          InkWell(onTap: onRemove, borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppTheme.cancelled, size: 18))),
        ],
      ),
    );
  }
}

class _UsefulLinkRow extends StatelessWidget {
  final CustomLink link;
  final VoidCallback onRemove;
  const _UsefulLinkRow({required this.link, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
            child: const Icon(Icons.link, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                Text(link.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
              ],
            ),
          ),
          InkWell(onTap: onRemove, borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppTheme.cancelled, size: 18))),
        ],
      ),
    );
  }
}

// ==========================================================================
// Appearance tab widgets
// ==========================================================================

class _LayoutCard extends StatelessWidget {
  final WebsiteLayout layout;
  final bool selected;
  final VoidCallback onTap;

  const _LayoutCard({required this.layout, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider, width: selected ? 1.6 : 1),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.9,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppTheme.divider, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 10),
                    if (layout == WebsiteLayout.grid) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Container(decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                            const SizedBox(width: 6),
                            Expanded(child: Container(decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Container(decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                            const SizedBox(width: 6),
                            Expanded(child: Container(decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                      const SizedBox(height: 6),
                      Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)))),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(layout.label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                if (selected) ...[const SizedBox(width: 6), const Icon(Icons.check_circle, color: AppTheme.primary, size: 16)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final ColorPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteCard({required this.palette, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(palette.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text(palette.subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            for (int i = 0; i < palette.colors.length; i++)
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: palette.colors[i], shape: BoxShape.circle, border: Border.all(color: AppTheme.divider, width: 1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatchField extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ColorSwatchField({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color ?? AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
            child: Icon(Icons.water_drop_outlined, color: color == null ? AppTheme.textSecondary : Colors.white.withValues(alpha: 0.9), size: 18),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerDialog extends StatelessWidget {
  const _ColorPickerDialog();

  static Future<Color?> show(BuildContext context) {
    return showDialog<Color>(context: context, builder: (context) => const _ColorPickerDialog());
  }

  static const _presets = [
    AppTheme.primary,
    AppTheme.primaryLight,
    AppTheme.primaryDark,
    AppTheme.accent,
    AppTheme.completed,
    AppTheme.cancelled,
    AppTheme.pending,
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFF9E9E9E),
    Color(0xFF5B4436),
    Color(0xFFA85C40),
    Color(0xFF3E8FD0),
    Color(0xFF5B4FE0),
    Color(0xFFE60023),
    Color(0xFF25D366),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pick a color', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presets
                  .map((color) => InkWell(
                        onTap: () => Navigator.pop(context, color),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider))),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
