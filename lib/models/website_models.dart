import 'package:flutter/material.dart';

/// Social platforms selectable from the "Select Social Links" sheet.
enum SocialPlatform { facebook, google, instagram, linkedin, pinterest, reddit, tiktok, whatsapp, twitter, youtube }

extension SocialPlatformInfo on SocialPlatform {
  String get label {
    switch (this) {
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.google:
        return 'Google';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.pinterest:
        return 'Pinterest';
      case SocialPlatform.reddit:
        return 'Reddit';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.whatsapp:
        return 'WhatsApp';
      case SocialPlatform.twitter:
        return 'X (Twitter)';
      case SocialPlatform.youtube:
        return 'YouTube';
    }
  }

  IconData get icon {
    switch (this) {
      case SocialPlatform.facebook:
        return Icons.facebook_rounded;
      case SocialPlatform.google:
        return Icons.g_mobiledata_rounded;
      case SocialPlatform.instagram:
        return Icons.camera_alt_rounded;
      case SocialPlatform.linkedin:
        return Icons.business_center_rounded;
      case SocialPlatform.pinterest:
        return Icons.push_pin_rounded;
      case SocialPlatform.reddit:
        return Icons.forum_rounded;
      case SocialPlatform.tiktok:
        return Icons.music_note_rounded;
      case SocialPlatform.whatsapp:
        return Icons.chat_rounded;
      case SocialPlatform.twitter:
        return Icons.close_rounded;
      case SocialPlatform.youtube:
        return Icons.play_arrow_rounded;
    }
  }

  /// Brand color used only for the small platform icon badge, kept
  /// separate from the app's orange/blue theme colors.
  Color get brandColor {
    switch (this) {
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.google:
        return const Color(0xFFEA4335);
      case SocialPlatform.instagram:
        return const Color(0xFFC13584);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.pinterest:
        return const Color(0xFFE60023);
      case SocialPlatform.reddit:
        return const Color(0xFFFF4500);
      case SocialPlatform.tiktok:
        return const Color(0xFF25F4EE);
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SocialPlatform.twitter:
        return const Color(0xFF0F1419);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
    }
  }

  String get urlHint => 'Enter Restaurant $label link';
}

class SocialLink {
  final SocialPlatform platform;
  final String url;
  const SocialLink({required this.platform, required this.url});

  SocialLink copyWith({String? url}) => SocialLink(platform: platform, url: url ?? this.url);
}

class CustomLink {
  final String title;
  final String url;
  final String? imageSource;
  const CustomLink({required this.title, required this.url, this.imageSource});
}

class ColorPalette {
  final String name;
  final String subtitle;
  final List<Color> colors;
  const ColorPalette({required this.name, required this.subtitle, required this.colors});
}

enum WebsiteLayout { grid, list }

extension WebsiteLayoutLabel on WebsiteLayout {
  String get label => this == WebsiteLayout.grid ? 'Grid Layout' : 'List Layout';
}
