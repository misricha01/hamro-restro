import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../data/repositories/staff_repository.dart';

/// "My Profile" -- read-only view of the logged-in user's own account.
/// Backed by `GET /api/user/profile` (distinct from `GET /api/user/{id}`,
/// which looks up any staff member by id).
///
/// NOTE: Swagger documents no response schema for this endpoint, so the
/// exact payload shape hasn't been confirmed live -- see the unwrap comment
/// in `StaffRepositoryImpl.getProfile()`. If the screen shows blank fields
/// on a real device, that unwrap logic is the first place to check.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final StaffRepository _repository;
  StaffMember? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = StaffRepositoryImpl(dioClient: context.read<DioClient>());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
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
        title: const Text('My Profile', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.cancelled, size: 36),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final initials = profile.fullname.trim().isEmpty
        ? '?'
        : profile.fullname.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.card,
                child: Text(initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
              ),
              const SizedBox(height: 12),
              Text(
                profile.fullname.isEmpty ? '--' : profile.fullname,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 4),
              Text(profile.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _ProfileField(label: 'Role', value: profile.role.isEmpty ? '--' : profile.role),
        _ProfileField(label: 'Position', value: profile.position?.isNotEmpty == true ? profile.position! : '--'),
        _ProfileField(label: 'Status', value: profile.status == false ? 'Inactive' : 'Active'),
        if (profile.isDefaultAdmin == true) _ProfileField(label: 'Account type', value: 'Super Admin'),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none))),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}