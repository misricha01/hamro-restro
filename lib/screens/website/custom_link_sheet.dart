import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/website_models.dart';
import '../create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// "Add Custom Link" bottom sheet, opened from the Website screen's Useful
/// Links "+ Add Links" action.
class AddCustomLinkSheet extends StatefulWidget {
  final CustomLink? initial;
  const AddCustomLinkSheet({super.key, this.initial});

  static Future<CustomLink?> show(BuildContext context, {CustomLink? initial}) {
    return showModalBottomSheet<CustomLink>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCustomLinkSheet(initial: initial),
    );
  }

  @override
  State<AddCustomLinkSheet> createState() => _AddCustomLinkSheetState();
}

class _AddCustomLinkSheetState extends State<AddCustomLinkSheet> {
  late final _titleController = TextEditingController(text: widget.initial?.title ?? '');
  late final _urlController = TextEditingController(text: widget.initial?.url ?? '');
  String? _imageSource;
  bool _titleError = false;
  bool _urlError = false;

  @override
  void initState() {
    super.initState();
    _imageSource = widget.initial?.imageSource;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _imageSource = result);
  }

  void _save() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty;
      _urlError = _urlController.text.trim().isEmpty;
    });
    if (_titleError || _urlError) return;
    Navigator.pop(
      context,
      CustomLink(title: _titleController.text.trim(), url: _urlController.text.trim(), imageSource: _imageSource),
    );
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
                      child: Text('Add Custom Link', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                      const Text('Link Image', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _imageSource == null ? 'Tap here to select or upload photos' : 'Selected via $_imageSource',
                                  style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                          children: [TextSpan(text: 'Custom Link Title'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        onChanged: (v) {
                          if (_titleError && v.trim().isNotEmpty) setState(() => _titleError = false);
                        },
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        decoration: InputDecoration(
                          hintText: 'Enter Link Title',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          errorText: _titleError ? 'Link title is required' : null,
                          errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
                          filled: true,
                          fillColor: AppTheme.card,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                          children: [TextSpan(text: 'Link URL'), TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled))],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        onChanged: (v) {
                          if (_urlError && v.trim().isNotEmpty) setState(() => _urlError = false);
                        },
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        decoration: InputDecoration(
                          hintText: 'Enter Link URL',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          errorText: _urlError ? 'Link URL is required' : null,
                          errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
                          filled: true,
                          fillColor: AppTheme.card,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
                        ),
                      ),
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
