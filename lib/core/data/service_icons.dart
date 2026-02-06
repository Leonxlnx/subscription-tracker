import 'package:flutter/material.dart';

class ServiceIcon {
  final String name;
  final IconData icon;
  final Color brandColor;
  final String category;
  final double defaultPrice;
  final String defaultCycle;

  const ServiceIcon({
    required this.name,
    required this.icon,
    required this.brandColor,
    required this.category,
    this.defaultPrice = 0,
    this.defaultCycle = 'monthly',
  });
}

class ServiceIcons {
  static const Map<String, ServiceIcon> services = {
    // Streaming
    'Netflix': ServiceIcon(
      name: 'Netflix',
      icon: Icons.play_circle_filled,
      brandColor: Color(0xFFE50914),
      category: 'streaming',
      defaultPrice: 13.99,
    ),
    'Disney+': ServiceIcon(
      name: 'Disney+',
      icon: Icons.castle_rounded,
      brandColor: Color(0xFF113CCF),
      category: 'streaming',
      defaultPrice: 8.99,
    ),
    'Amazon Prime': ServiceIcon(
      name: 'Amazon Prime',
      icon: Icons.local_shipping_rounded,
      brandColor: Color(0xFF00A8E1),
      category: 'streaming',
      defaultPrice: 8.99,
    ),
    'HBO Max': ServiceIcon(
      name: 'HBO Max',
      icon: Icons.movie_filter_rounded,
      brandColor: Color(0xFF5822B4),
      category: 'streaming',
      defaultPrice: 9.99,
    ),
    'Apple TV+': ServiceIcon(
      name: 'Apple TV+',
      icon: Icons.tv_rounded,
      brandColor: Color(0xFF555555),
      category: 'streaming',
      defaultPrice: 9.99,
    ),
    'Hulu': ServiceIcon(
      name: 'Hulu',
      icon: Icons.live_tv_rounded,
      brandColor: Color(0xFF1CE783),
      category: 'streaming',
      defaultPrice: 7.99,
    ),
    'Paramount+': ServiceIcon(
      name: 'Paramount+',
      icon: Icons.terrain_rounded,
      brandColor: Color(0xFF0064FF),
      category: 'streaming',
      defaultPrice: 5.99,
    ),
    'Crunchyroll': ServiceIcon(
      name: 'Crunchyroll',
      icon: Icons.animation_rounded,
      brandColor: Color(0xFFF47521),
      category: 'streaming',
      defaultPrice: 7.99,
    ),

    // Music
    'Spotify': ServiceIcon(
      name: 'Spotify',
      icon: Icons.graphic_eq_rounded,
      brandColor: Color(0xFF1DB954),
      category: 'music',
      defaultPrice: 9.99,
    ),
    'Apple Music': ServiceIcon(
      name: 'Apple Music',
      icon: Icons.music_note_rounded,
      brandColor: Color(0xFFFC3C44),
      category: 'music',
      defaultPrice: 10.99,
    ),
    'YouTube Premium': ServiceIcon(
      name: 'YouTube Premium',
      icon: Icons.smart_display_rounded,
      brandColor: Color(0xFFFF0000),
      category: 'streaming',
      defaultPrice: 13.99,
    ),
    'Tidal': ServiceIcon(
      name: 'Tidal',
      icon: Icons.waves_rounded,
      brandColor: Color(0xFF000000),
      category: 'music',
      defaultPrice: 10.99,
    ),
    'SoundCloud Go': ServiceIcon(
      name: 'SoundCloud Go',
      icon: Icons.cloud_rounded,
      brandColor: Color(0xFFFF5500),
      category: 'music',
      defaultPrice: 5.99,
    ),
    'Deezer': ServiceIcon(
      name: 'Deezer',
      icon: Icons.equalizer_rounded,
      brandColor: Color(0xFFA238FF),
      category: 'music',
      defaultPrice: 10.99,
    ),

    // Gaming
    'Xbox Game Pass': ServiceIcon(
      name: 'Xbox Game Pass',
      icon: Icons.gamepad_rounded,
      brandColor: Color(0xFF107C10),
      category: 'gaming',
      defaultPrice: 14.99,
    ),
    'PlayStation Plus': ServiceIcon(
      name: 'PlayStation Plus',
      icon: Icons.sports_esports_rounded,
      brandColor: Color(0xFF003791),
      category: 'gaming',
      defaultPrice: 8.99,
    ),
    'Nintendo Switch Online': ServiceIcon(
      name: 'Nintendo Switch Online',
      icon: Icons.videogame_asset_rounded,
      brandColor: Color(0xFFE60012),
      category: 'gaming',
      defaultPrice: 3.99,
    ),
    'Google Play Pass': ServiceIcon(
      name: 'Google Play Pass',
      icon: Icons.play_arrow_rounded,
      brandColor: Color(0xFF01875F),
      category: 'gaming',
      defaultPrice: 4.99,
    ),
    'EA Play': ServiceIcon(
      name: 'EA Play',
      icon: Icons.shield_rounded,
      brandColor: Color(0xFF000000),
      category: 'gaming',
      defaultPrice: 4.99,
    ),

    // AI & Tech
    'ChatGPT Plus': ServiceIcon(
      name: 'ChatGPT Plus',
      icon: Icons.auto_awesome_rounded,
      brandColor: Color(0xFF10A37F),
      category: 'productivity',
      defaultPrice: 20.00,
    ),
    'Claude Pro': ServiceIcon(
      name: 'Claude Pro',
      icon: Icons.psychology_rounded,
      brandColor: Color(0xFFD97757),
      category: 'productivity',
      defaultPrice: 20.00,
    ),
    'Gemini Advanced': ServiceIcon(
      name: 'Gemini Advanced',
      icon: Icons.diamond_rounded,
      brandColor: Color(0xFF4285F4),
      category: 'productivity',
      defaultPrice: 21.99,
    ),
    'GitHub Copilot': ServiceIcon(
      name: 'GitHub Copilot',
      icon: Icons.code_rounded,
      brandColor: Color(0xFF000000),
      category: 'productivity',
      defaultPrice: 10.00,
    ),
    'Midjourney': ServiceIcon(
      name: 'Midjourney',
      icon: Icons.palette_rounded,
      brandColor: Color(0xFF000000),
      category: 'productivity',
      defaultPrice: 10.00,
    ),
    'Perplexity Pro': ServiceIcon(
      name: 'Perplexity Pro',
      icon: Icons.search_rounded,
      brandColor: Color(0xFF20808D),
      category: 'productivity',
      defaultPrice: 20.00,
    ),

    // Social & Communication
    'Discord Nitro': ServiceIcon(
      name: 'Discord Nitro',
      icon: Icons.forum_rounded,
      brandColor: Color(0xFF5865F2),
      category: 'other',
      defaultPrice: 9.99,
    ),
    'X Premium': ServiceIcon(
      name: 'X Premium',
      icon: Icons.alternate_email_rounded,
      brandColor: Color(0xFF000000),
      category: 'other',
      defaultPrice: 8.00,
    ),
    'LinkedIn Premium': ServiceIcon(
      name: 'LinkedIn Premium',
      icon: Icons.business_center_rounded,
      brandColor: Color(0xFF0A66C2),
      category: 'other',
      defaultPrice: 29.99,
    ),
    'Reddit Premium': ServiceIcon(
      name: 'Reddit Premium',
      icon: Icons.smart_toy_rounded,
      brandColor: Color(0xFFFF4500),
      category: 'other',
      defaultPrice: 5.99,
    ),
    'Telegram Premium': ServiceIcon(
      name: 'Telegram Premium',
      icon: Icons.send_rounded,
      brandColor: Color(0xFF2AABEE),
      category: 'other',
      defaultPrice: 4.99,
    ),

    // Cloud & Storage
    'iCloud+': ServiceIcon(
      name: 'iCloud+',
      icon: Icons.cloud_done_rounded,
      brandColor: Color(0xFF3693F5),
      category: 'cloud',
      defaultPrice: 2.99,
    ),
    'Google One': ServiceIcon(
      name: 'Google One',
      icon: Icons.backup_rounded,
      brandColor: Color(0xFF4285F4),
      category: 'cloud',
      defaultPrice: 1.99,
    ),
    'Dropbox Plus': ServiceIcon(
      name: 'Dropbox Plus',
      icon: Icons.inventory_2_rounded,
      brandColor: Color(0xFF0061FF),
      category: 'cloud',
      defaultPrice: 11.99,
    ),
    'OneDrive': ServiceIcon(
      name: 'OneDrive',
      icon: Icons.cloud_circle_rounded,
      brandColor: Color(0xFF0078D4),
      category: 'cloud',
      defaultPrice: 1.99,
    ),

    // Productivity
    'Microsoft 365': ServiceIcon(
      name: 'Microsoft 365',
      icon: Icons.grid_view_rounded,
      brandColor: Color(0xFFD83B01),
      category: 'productivity',
      defaultPrice: 6.99,
    ),
    'Notion': ServiceIcon(
      name: 'Notion',
      icon: Icons.article_rounded,
      brandColor: Color(0xFF000000),
      category: 'productivity',
      defaultPrice: 8.00,
    ),
    'Figma': ServiceIcon(
      name: 'Figma',
      icon: Icons.design_services_rounded,
      brandColor: Color(0xFFF24E1E),
      category: 'productivity',
      defaultPrice: 12.00,
    ),
    'Canva Pro': ServiceIcon(
      name: 'Canva Pro',
      icon: Icons.brush_rounded,
      brandColor: Color(0xFF00C4CC),
      category: 'productivity',
      defaultPrice: 12.99,
    ),
    'Adobe Creative Cloud': ServiceIcon(
      name: 'Adobe Creative Cloud',
      icon: Icons.photo_filter_rounded,
      brandColor: Color(0xFFFF0000),
      category: 'productivity',
      defaultPrice: 54.99,
    ),
    'Grammarly': ServiceIcon(
      name: 'Grammarly',
      icon: Icons.spellcheck_rounded,
      brandColor: Color(0xFF15C39A),
      category: 'productivity',
      defaultPrice: 12.00,
    ),
    '1Password': ServiceIcon(
      name: '1Password',
      icon: Icons.lock_rounded,
      brandColor: Color(0xFF0572EC),
      category: 'productivity',
      defaultPrice: 2.99,
    ),
    'NordVPN': ServiceIcon(
      name: 'NordVPN',
      icon: Icons.vpn_lock_rounded,
      brandColor: Color(0xFF4687FF),
      category: 'productivity',
      defaultPrice: 4.49,
    ),
    'Todoist Pro': ServiceIcon(
      name: 'Todoist Pro',
      icon: Icons.check_circle_rounded,
      brandColor: Color(0xFFE44332),
      category: 'productivity',
      defaultPrice: 4.00,
    ),
    'Evernote': ServiceIcon(
      name: 'Evernote',
      icon: Icons.note_alt_rounded,
      brandColor: Color(0xFF00A82D),
      category: 'productivity',
      defaultPrice: 7.99,
    ),
    'Slack Pro': ServiceIcon(
      name: 'Slack Pro',
      icon: Icons.tag_rounded,
      brandColor: Color(0xFF4A154B),
      category: 'productivity',
      defaultPrice: 7.25,
    ),

    // Fitness
    'Strava': ServiceIcon(
      name: 'Strava',
      icon: Icons.directions_run_rounded,
      brandColor: Color(0xFFFC4C02),
      category: 'fitness',
      defaultPrice: 7.99,
    ),
    'Peloton': ServiceIcon(
      name: 'Peloton',
      icon: Icons.fitness_center_rounded,
      brandColor: Color(0xFF000000),
      category: 'fitness',
      defaultPrice: 12.99,
    ),
    'MyFitnessPal': ServiceIcon(
      name: 'MyFitnessPal',
      icon: Icons.restaurant_rounded,
      brandColor: Color(0xFF0070D1),
      category: 'fitness',
      defaultPrice: 9.99,
    ),
    'Headspace': ServiceIcon(
      name: 'Headspace',
      icon: Icons.self_improvement_rounded,
      brandColor: Color(0xFFF47D31),
      category: 'fitness',
      defaultPrice: 12.99,
    ),
    'Calm': ServiceIcon(
      name: 'Calm',
      icon: Icons.spa_rounded,
      brandColor: Color(0xFF4891D4),
      category: 'fitness',
      defaultPrice: 14.99,
    ),

    // News & Media
    'Medium': ServiceIcon(
      name: 'Medium',
      icon: Icons.menu_book_rounded,
      brandColor: Color(0xFF000000),
      category: 'news',
      defaultPrice: 5.00,
    ),
    'The New York Times': ServiceIcon(
      name: 'The New York Times',
      icon: Icons.newspaper_rounded,
      brandColor: Color(0xFF000000),
      category: 'news',
      defaultPrice: 4.25,
    ),
    'Audible': ServiceIcon(
      name: 'Audible',
      icon: Icons.headphones_rounded,
      brandColor: Color(0xFFF8991D),
      category: 'news',
      defaultPrice: 9.95,
    ),
    'Kindle Unlimited': ServiceIcon(
      name: 'Kindle Unlimited',
      icon: Icons.auto_stories_rounded,
      brandColor: Color(0xFF1A8FCE),
      category: 'news',
      defaultPrice: 11.99,
    ),
    'Twitch Turbo': ServiceIcon(
      name: 'Twitch Turbo',
      icon: Icons.videocam_rounded,
      brandColor: Color(0xFF9146FF),
      category: 'streaming',
      defaultPrice: 8.99,
    ),
  };

  static ServiceIcon? getService(String name) {
    // Try exact match first
    if (services.containsKey(name)) return services[name];
    // Try case-insensitive match
    final lower = name.toLowerCase();
    for (final entry in services.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  static List<ServiceIcon> getByCategory(String category) {
    return services.values
        .where((s) => s.category == category)
        .toList();
  }

  static List<ServiceIcon> get allServices => services.values.toList();

  static Color getDefaultColor(String serviceName) {
    return getService(serviceName)?.brandColor ?? const Color(0xFF666666);
  }
}
