import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/printer.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/setting_empty_state.dart';
import 'add_printer_screen.dart';

enum _ConnectionMode { bluetooth, network }

/// "Printers" screen reached from Manage > Setting > Order Setting (and
/// Orders' 3-dot Actions menu): manage configured printers. Tapping a
/// printer's edit icon reuses [AddPrinterScreen] pre-filled with its
/// details instead of a separate edit flow.
class PrintersSettingScreen extends StatefulWidget {
  const PrintersSettingScreen({super.key});

  @override
  State<PrintersSettingScreen> createState() => _PrintersSettingScreenState();
}

class _PrintersSettingScreenState extends State<PrintersSettingScreen> {
  final List<Printer> _printers = [];
  final _searchController = TextEditingController();
  bool _searching = false;
  _ConnectionMode _connectionMode = _ConnectionMode.bluetooth;
  bool _cloudMode = false;

  List<Printer> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _printers;
    return _printers.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addPrinter() async {
    final printer = await Navigator.push<Printer>(context, MaterialPageRoute(builder: (context) => const AddPrinterScreen()));
    if (printer != null) setState(() => _printers.add(printer));
  }

  Future<void> _editPrinter(int index) async {
    final updated = await Navigator.push<Printer>(context, MaterialPageRoute(builder: (context) => AddPrinterScreen(initial: _printers[index])));
    if (updated != null) setState(() => _printers[index] = updated);
  }

  void _pickConnectionMode() async {
    final mode = await showModalBottomSheet<_ConnectionMode>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bluetooth, color: AppTheme.textPrimary),
              title: const Text('Bluetooth', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
              onTap: () => Navigator.pop(context, _ConnectionMode.bluetooth),
            ),
            ListTile(
              leading: const Icon(Icons.wifi, color: AppTheme.textPrimary),
              title: const Text('Network', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
              onTap: () => Navigator.pop(context, _ConnectionMode.network),
            ),
          ],
        ),
      ),
    );
    if (mode != null) setState(() => _connectionMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final printers = _filtered;
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
        title: const Text('Printers', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          GestureDetector(
            onTap: _pickConnectionMode,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_connectionMode == _ConnectionMode.bluetooth ? Icons.bluetooth : Icons.wifi, color: AppTheme.textPrimary, size: 16),
                  const SizedBox(width: 4),
                  Text(_connectionMode == _ConnectionMode.bluetooth ? 'Bluetooth' : 'Network', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
          ManageAppBarIconButton(icon: Icons.search, active: _searching, onTap: () => setState(() => _searching = !_searching)),
          PopupMenuButton<String>(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
            onSelected: (value) {
              if (value == 'test') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Testing all printers...')));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.print_outlined, color: AppTheme.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text('Test All Printers', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) => Row(
                    children: [
                      const Icon(Icons.print_outlined, color: AppTheme.textPrimary, size: 20),
                      const SizedBox(width: 10),
                      const Text('Mode', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                      const Spacer(),
                      const Text('Local', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                      Switch(
                        value: _cloudMode,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (v) => setState(() { _cloudMode = v; setMenuState(() {}); }),
                      ),
                      const Text('Cloud', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searching)
              ManageSearchField(
                controller: _searchController,
                onClose: () => setState(() { _searching = false; _searchController.clear(); }),
                onChanged: (_) => setState(() {}),
              ),
            Expanded(
              child: printers.isEmpty
                  ? (_connectionMode == _ConnectionMode.bluetooth
                      ? _NoPairedDevices(onGoToSettings: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Bluetooth settings...'))), onRefresh: () => setState(() {}))
                      : SettingEmptyState(
                          title: 'Printer',
                          subtitle: 'No Printer found. Needs to create the Printer!',
                          actionLabel: 'Create New Printer',
                          onAction: _addPrinter,
                        ))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: printers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final printer = printers[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                          child: Row(
                            children: [
                              const Icon(Icons.print_outlined, color: AppTheme.accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(printer.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                    const SizedBox(height: 2),
                                    Text('${printer.paperWidth} · ${printer.ipAddress.isEmpty ? 'No IP set' : printer.ipAddress}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _editPrinter(index),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: printers.isEmpty
          ? null
          : FloatingActionButton(backgroundColor: AppTheme.primary, onPressed: _addPrinter, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}

class _NoPairedDevices extends StatelessWidget {
  final VoidCallback onGoToSettings;
  final VoidCallback onRefresh;
  const _NoPairedDevices({required this.onGoToSettings, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_disabled, size: 90, color: AppTheme.accent.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
                TextSpan(text: 'Paired Devices', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
              ]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please navigate to system setting and pair your bluetooth device using correct PIN',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.4, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onGoToSettings,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Go to Setting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRefresh,
              child: const Text('Refresh', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }
}
