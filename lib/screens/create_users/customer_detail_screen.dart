import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer/customer_model.dart';
import '../../providers/customer_comment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/analytics_cards.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import '../finance/payments/payment_entry_screen.dart';
import 'add_customer_screen.dart' show AddCustomerScreen;

enum _CustomerMenuAction { edit, remove, help }

/// Customer profile screen reached by tapping a row in [CustomerListScreen].
/// Deletion calls [CustomerProvider.deleteCustomer] (`DELETE
/// /api/customers/{id}`) directly rather than a passed-in callback.
/// Transactions/Invoice/Credit List tabs stay static placeholders — no
/// backend endpoint confirmed for those yet. The Comments tab is backed by
/// [CustomerCommentProvider] (`/api/customer-comments`) — the nested
/// `customer.comments` from the detail response isn't reliable (unconfirmed
/// on GET), so this always fetches via the dedicated endpoint instead.
class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer _customer = widget.customer;
  int _tabIndex = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final commentProvider = context.read<CustomerCommentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => commentProvider.fetchComments(_customer.id));
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Customer>(context, MaterialPageRoute(builder: (context) => AddCustomerScreen(existingCustomer: _customer)));
    if (updated != null && mounted) setState(() => _customer = updated);
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Remove Customer', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          "Remove ${_customer.customerName} from your customer list?",
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final provider = context.read<CustomerProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteCustomer(_customer.id);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to remove customer')));
    }
  }

  void _handleMenuAction(_CustomerMenuAction action) {
    switch (action) {
      case _CustomerMenuAction.edit:
        _edit();
      case _CustomerMenuAction.remove:
        _confirmRemove();
      case _CustomerMenuAction.help:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & support coming soon')));
    }
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
        title: Text(
          _customer.customerName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accent)),
                  )
                : PopupMenuButton<_CustomerMenuAction>(
                    onSelected: _handleMenuAction,
                    color: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: _CustomerMenuAction.edit, child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit Customer')),
                      PopupMenuDivider(),
                      PopupMenuItem(value: _CustomerMenuAction.remove, child: _MenuRow(icon: Icons.delete_outline, label: 'Remove Customer', color: AppTheme.cancelled)),
                      PopupMenuDivider(),
                      PopupMenuItem(value: _CustomerMenuAction.help, child: _MenuRow(icon: Icons.help_outline, label: 'Help')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _DetailTabRow(
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _ProfileTab(
                    customer: _customer,
                    onPaymentIn: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: true))),
                    onPaymentOut: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: false))),
                  ),
                  const InvoiceEmptyState(entityName: 'Transactions'),
                  const InvoiceEmptyState(entityName: 'Invoice'),
                  const _CreditListTab(),
                  _CommentsTab(customerId: _customer.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuRow({required this.icon, required this.label, this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
      ],
    );
  }
}

class _DetailTabRow extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _DetailTabRow({required this.index, required this.onChanged});

  static const _labels = ['Profile', 'Transactions', 'Invoice', 'Credit List', 'Comments'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labels[i],
                    style: TextStyle(
                      color: index == i ? AppTheme.cancelled : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, width: 44, color: index == i ? AppTheme.cancelled : Colors.transparent),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CreditListTab extends StatefulWidget {
  const _CreditListTab();

  @override
  State<_CreditListTab> createState() => _CreditListTabState();
}

class _CreditListTabState extends State<_CreditListTab> {
  String _dateFilter = 'Life Time';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              AnalyticsFilterDropdown(
                label: _dateFilter,
                options: kAnalyticsDateFilterOptions,
                onSelected: (v) => setState(() => _dateFilter = v),
              ),
            ],
          ),
        ),
        const Expanded(child: InvoiceEmptyState(entityName: 'Credit List')),
      ],
    );
  }
}

/// Comments tab, backed by [CustomerCommentProvider] (`/api/customer-comments`).
class _CommentsTab extends StatefulWidget {
  final String customerId;
  const _CommentsTab({required this.customerId});

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab> {
  final _newCommentController = TextEditingController();

  @override
  void dispose() {
    _newCommentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _newCommentController.text.trim();
    if (text.isEmpty) return;
    final provider = context.read<CustomerCommentProvider>();
    final created = await provider.addComment(text);
    if (!mounted) return;
    if (created != null) {
      _newCommentController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  Future<void> _editComment(CustomerComment comment) async {
    final controller = TextEditingController(text: comment.comment);
    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit Comment', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newText == null || newText.isEmpty || newText == comment.comment || comment.id == null) return;

    final provider = context.read<CustomerCommentProvider>();
    final ok = await provider.updateComment(id: comment.id!, comment: newText);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.updateErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  Future<void> _deleteComment(CustomerComment comment) async {
    if (comment.id == null) return;
    final provider = context.read<CustomerCommentProvider>();
    final ok = await provider.deleteComment(comment.id!);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerCommentProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _newCommentController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    filled: true,
                    fillColor: AppTheme.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: provider.isCreating ? null : _addComment,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: provider.isCreating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(CustomerCommentProvider provider) {
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
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchComments(widget.customerId),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.comments.isEmpty) {
          return const InvoiceEmptyState(entityName: 'Comments');
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchComments(widget.customerId),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: provider.comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final comment = provider.comments[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(comment.comment, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, decoration: TextDecoration.none)),
                    ),
                    if (comment.id != null) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _editComment(comment),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _deleteComment(comment),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
    }
  }
}

class _ProfileTab extends StatelessWidget {
  final Customer customer;
  final VoidCallback onPaymentIn;
  final VoidCallback onPaymentOut;

  const _ProfileTab({required this.customer, required this.onPaymentIn, required this.onPaymentOut});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SummaryCard(customer: customer),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _TintedButton(label: 'Payment Out (Payment)', icon: Icons.south_west, color: AppTheme.cancelled, onTap: onPaymentOut),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TintedButton(label: 'Payment In (Receipt)', icon: Icons.trending_up, color: AppTheme.completed, onTap: onPaymentIn),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Details', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
          child: Column(
            children: [
              _DetailRow(
                label: 'Contact',
                value: Text(customer.phoneNumber, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
              _DetailRow(
                label: 'Email',
                value: Text(customer.emailAddress ?? '-', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
              if (customer.companyName != null)
                _DetailRow(
                  label: 'Company',
                  value: Text(customer.companyName!, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.panVatNumber != null)
                _DetailRow(
                  label: 'PAN/VAT',
                  value: Text(customer.panVatNumber!, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.discount != null)
                _DetailRow(
                  label: 'Discount',
                  value: Text('${customer.discount}%', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.customerGroup != null)
                _DetailRow(
                  label: 'Group',
                  value: Text(customer.customerGroup!.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.favouriteDish != null)
                _DetailRow(
                  label: 'Favourite Dish',
                  value: Text(customer.favouriteDish!.dishName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.preferredSeating != null)
                _DetailRow(
                  label: 'Preferred Seat',
                  value: Text(customer.preferredSeating!.tableName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.dietaryType != null)
                _DetailRow(
                  label: 'Dietary Type',
                  value: Text(customer.dietaryType!.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              if (customer.startPreferredTime != null || customer.endPreferredTime != null)
                _DetailRow(
                  label: 'Preferred Time',
                  value: Text(
                    '${customer.startPreferredTime ?? '—'} - ${customer.endPreferredTime ?? '—'}',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              _DetailRow(
                label: 'Allergies',
                value: Text(customer.allergies ?? '-', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          const Text(':  ', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Customer customer;
  const _SummaryCard({required this.customer});

  String get _initials {
    final parts = customer.customerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
            child: Text(_initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.customerName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                const SizedBox(height: 2),
                Text(customer.phoneNumber, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TintedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TintedButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5, decoration: TextDecoration.none))),
          ],
        ),
      ),
    );
  }
}
