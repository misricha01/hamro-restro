import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// "Select Printers" sheet opened from a screen's Print action (e.g. Top
/// Selling Sub Menus). Mirrors the other "select_X_sheet" pickers' empty
/// state (circle icon + "No X" heading + subtext), with a full-width Print
/// button in place of a create-new action since printers are set up
/// elsewhere (Manage > Restaurant Setting > Printer).
class SelectPrinterSheet extends StatelessWidget {
  const SelectPrinterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectPrinterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
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
                    const Text(
                      'Select Printers',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
                                child: const Icon(Icons.print_outlined, color: AppTheme.accent, size: 56),
                              ),
                              const SizedBox(height: 24),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                                  children: [
                                    TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                                    TextSpan(text: 'Printer', style: TextStyle(color: AppTheme.accent)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No Printer found. Needs to create the Printer!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Print', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
