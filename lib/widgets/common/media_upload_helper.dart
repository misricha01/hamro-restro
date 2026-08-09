import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/media/media_model.dart';
import '../../providers/media_provider.dart';
import '../../screens/create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// Shows [ImageSourceSheet] for the user to pick a source, launches the
/// native camera/gallery picker via `image_picker`, then uploads the result
/// through [MediaProvider.uploadFile] (`POST /api/media`) — showing a
/// blocking progress dialog for the upload itself, since callers need the
/// real [UploadedMedia.id] before they can save.
///
/// "Open Hamro Restro's Library" has no backend behind it (there's no
/// `GET /api/media` list endpoint to browse previously-uploaded files
/// against), so it stays a "coming soon" no-op rather than pretending to
/// work — matches how every other screen in this app treats a genuinely
/// missing backend capability rather than faking one.
///
/// Returns `null` if the user cancels at any step, or if the pick/upload
/// fails (a snackbar is shown for upload failures; pick cancellation is
/// silent, matching the platform picker's own UX).
Future<UploadedMedia?> pickAndUploadImage(BuildContext context, {bool includeLibrary = true}) async {
  final source = await ImageSourceSheet.show(context, includeLibrary: includeLibrary);
  if (source == null || !context.mounted) return null;

  if (source == 'library') {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hamro Restro's Library is coming soon")));
    return null;
  }

  final picker = ImagePicker();
  XFile? picked;
  try {
    picked = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open ${source == 'camera' ? 'camera' : 'gallery'}: $e')));
    }
    return null;
  }
  if (picked == null || !context.mounted) return null;

  final provider = context.read<MediaProvider>();
  final messenger = ScaffoldMessenger.of(context);

  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _UploadingDialog(),
  ));

  final media = await provider.uploadFile(picked.path);

  if (context.mounted) Navigator.of(context, rootNavigator: true).pop(); // close the uploading dialog

  if (media == null && context.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(provider.uploadErrorMessage ?? 'Failed to upload photo')));
  }
  return media;
}

class _UploadingDialog extends StatelessWidget {
  const _UploadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accent)),
            SizedBox(width: 16),
            Text('Uploading photo…', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
