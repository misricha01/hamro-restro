import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class _CategorizedFaq {
  final String question;
  final String answer;
  final String category;
  const _CategorizedFaq(this.question, this.answer, this.category);
}

/// Full "FAQs" screen reached from Home's FAQ card "View All". Mirrors the
/// reference screenshot's category-filtered accordion layout, restyled to
/// the app's dark orange/blue theme instead of the reference's light/red one.
class FaqListScreen extends StatefulWidget {
  const FaqListScreen({super.key});

  @override
  State<FaqListScreen> createState() => _FaqListScreenState();
}

class _FaqListScreenState extends State<FaqListScreen> {
  String _category = 'All';

  static const _categories = ['All', 'General', 'Accounts', 'Sign In/Log In', 'Sales', 'Support'];

  static const _faqs = [
    _CategorizedFaq(
      'What is Hamro Restro?',
      'Hamro Restro is an ultimate restaurant operating system gathered with high-end features compacted all in one app. It brings together integrated online ordering, inventory tracking, staff management and business reports in a single cloud-based system.',
      'General',
    ),
    _CategorizedFaq(
      'How does Hamro Restro work?',
      'Set up your restaurant, add your menu and tables, then start taking orders from a single dashboard.',
      'General',
    ),
    _CategorizedFaq(
      'Is Hamro Restro secure?',
      'Hamro Restro guarantees that your data and privacy are secured and well protected, with several security features to add an extra layer of protection to your account.',
      'General',
    ),
    _CategorizedFaq(
      'Are there mobile and portable options?',
      'Yes — Hamro Restro runs on Android phones and tablets so you can take orders and manage your restaurant from anywhere on the floor.',
      'General',
    ),
    _CategorizedFaq(
      'Can I get access to my financial report?',
      'Yes, the Finance and Reports sections give you real-time access to your sales, expenses and profit & loss figures.',
      'General',
    ),
    _CategorizedFaq(
      'How to recover my password?/ How can I reset my pasword?',
      'You can recover your password by clicking on the forgot password button. A password reset link will be sent to your registered email, which you can use to set a new password.',
      'Accounts',
    ),
    _CategorizedFaq(
      'What happens after I download Hamro Restro app?',
      'After downloading the app, new users are asked to sign up; existing users can simply log in to their account.',
      'Accounts',
    ),
    _CategorizedFaq(
      'How to get started?',
      'You can get started by registering your restaurant, then following the setup guide on the Home screen to add your first table, dish and staff member.',
      'Accounts',
    ),
    _CategorizedFaq(
      'How long will it take to register/sign in?',
      'Registration takes just a couple of minutes — you only need your restaurant name, email and a password to get started.',
      'Sign In/Log In',
    ),
    _CategorizedFaq(
      "I forgot my password. How do I log into Hamro Restro?",
      'Tap the forgot password link on the login screen. You will receive a verification email to set a new password, which you can then use to log in. Contact support if you run into any difficulty.',
      'Sign In/Log In',
    ),
    _CategorizedFaq(
      'My restaurant uses the free version of this app. Can I get full support through chat whenever we have some system queries?',
      'Yes, chat support is available to all restaurants regardless of plan — tap "Talk to us" below to start a conversation.',
      'Sales',
    ),
    _CategorizedFaq(
      'How can my restaurant benefit from Hamro Restro?',
      'Hamro Restro streamlines order taking, billing, inventory and staff management, saving time and reducing errors.',
      'Sales',
    ),
    _CategorizedFaq(
      "I already have a restaurant's private website. Why do I need Hamro Restro?",
      'Running a restaurant smoothly requires many areas of operation. Hamro Restro brings all of them — ordering, billing, inventory, staff — into one system alongside your existing website.',
      'Sales',
    ),
    _CategorizedFaq(
      'Is there any service where you provide us with pieces of training on how to use the system?',
      'Yes — our support team can walk you through onboarding and best practices for your restaurant.',
      'Support',
    ),
    _CategorizedFaq(
      'Is Hamro Restro suitable for my restaurant business?',
      'Hamro Restro is built for restaurants, cafes, bars and cloud kitchens of any size, from a single table to multi-branch operations.',
      'Support',
    ),
  ];

  List<_CategorizedFaq> get _filtered {
    if (_category == 'All') return _faqs;
    return _faqs.where((f) => f.category == _category).toList();
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
          'FAQs',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                const Text(
                  'Top Questions',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((c) {
                    final selected = c == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : AppTheme.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Column(
                    children: [
                      for (final faq in _filtered)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            iconColor: AppTheme.textSecondary,
                            collapsedIconColor: AppTheme.textSecondary,
                            title: Text(
                              faq.question,
                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                            ),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq.answer,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4, decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...'))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.completed,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                label: const Text('Talk to us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
