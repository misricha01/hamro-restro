import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Small building blocks shared by every Cash & Banks detail screen
/// ([CashBankAccountDetailScreen] and [CashBankModeDetailScreen]) so both
/// reuse the same avatar and list-row treatment instead of duplicating them.

class CashBankInitialsAvatar extends StatelessWidget {
  final String text;
  const CashBankInitialsAvatar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
    );
  }
}

class CashBankListRow extends StatelessWidget {
  final String initials;
  final String label;
  const CashBankListRow({super.key, required this.initials, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          CashBankInitialsAvatar(text: initials),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none))),
          const Icon(Icons.star_border, color: AppTheme.textSecondary, size: 20),
        ],
      ),
    );
  }
}

/// The "avatar + name/Rs balance + divider + labelled stat row" summary card
/// shown at the top of every Cash & Banks detail screen.
class CashBankSummaryCard extends StatelessWidget {
  final String initials;
  final String name;
  final double balance;
  final String statLabel;
  final String statValue;

  const CashBankSummaryCard({
    super.key,
    required this.initials,
    required this.name,
    required this.balance,
    required this.statLabel,
    required this.statValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CashBankInitialsAvatar(text: initials),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text('Rs ${balance.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(statLabel, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
              const Spacer(),
              Text(statValue, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
            ],
          ),
        ],
      ),
    );
  }
}
