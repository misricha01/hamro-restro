import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/website_models.dart';

/// "Select Social Links" bottom sheet, opened from the Website screen's
/// Social Links "+ Add Links" action. Lets the user multi-select which
/// platforms to add, then hand off to [SocialLinkUrlsSheet] to collect the
/// URL for each selected platform.
class SelectSocialLinksSheet extends StatefulWidget {
  final Set<SocialPlatform> initial;
  const SelectSocialLinksSheet({super.key, this.initial = const {}});

  static Future<Set<SocialPlatform>?> show(BuildContext context, {Set<SocialPlatform> initial = const {}}) {
    return showModalBottomSheet<Set<SocialPlatform>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectSocialLinksSheet(initial: initial),
    );
  }

  @override
  State<SelectSocialLinksSheet> createState() => _SelectSocialLinksSheetState();
}

class _SelectSocialLinksSheetState extends State<SelectSocialLinksSheet> {
  late final Set<SocialPlatform> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.86),
        decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Select Social Links', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: SocialPlatform.values.map((platform) {
                      final selected = _selected.contains(platform);
                      return _PlatformTile(
                        platform: platform,
                        selected: selected,
                        onTap: () => setState(() {
                          if (selected) {
                            _selected.remove(platform);
                          } else {
                            _selected.add(platform);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Discard', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final SocialPlatform platform;
  final bool selected;
  final VoidCallback onTap;

  const _PlatformTile({required this.platform, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider, width: selected ? 1.4 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: platform.brandColor, shape: BoxShape.circle),
              child: Icon(platform.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              platform.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Second step of the Social Links flow: collects a URL for each platform
/// selected in [SelectSocialLinksSheet], pre-filled from any [existing]
/// links so re-opening "Add Links" doesn't lose previously saved URLs.
class SocialLinkUrlsSheet extends StatefulWidget {
  final List<SocialPlatform> platforms;
  final List<SocialLink> existing;
  const SocialLinkUrlsSheet({super.key, required this.platforms, this.existing = const []});

  static Future<List<SocialLink>?> show(BuildContext context, {required List<SocialPlatform> platforms, List<SocialLink> existing = const []}) {
    return showModalBottomSheet<List<SocialLink>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialLinkUrlsSheet(platforms: platforms, existing: existing),
    );
  }

  @override
  State<SocialLinkUrlsSheet> createState() => _SocialLinkUrlsSheetState();
}

class _SocialLinkUrlsSheetState extends State<SocialLinkUrlsSheet> {
  late final Map<SocialPlatform, TextEditingController> _controllers = {
    for (final platform in widget.platforms)
      platform: TextEditingController(
        text: widget.existing.firstWhere((e) => e.platform == platform, orElse: () => SocialLink(platform: platform, url: '')).url,
      ),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final links = _controllers.entries.where((e) => e.value.text.trim().isNotEmpty).map((e) => SocialLink(platform: e.key, url: e.value.text.trim())).toList();
    Navigator.pop(context, links);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.86),
        decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Add Social Links', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final platform in widget.platforms) ...[
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: platform.brandColor, shape: BoxShape.circle),
                              child: Icon(platform.icon, color: Colors.white, size: 15),
                            ),
                            const SizedBox(width: 8),
                            Text(platform.label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controllers[platform],
                          keyboardType: TextInputType.url,
                          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                          decoration: InputDecoration(
                            hintText: platform.urlHint,
                            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                            filled: true,
                            fillColor: AppTheme.card,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Discard', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
