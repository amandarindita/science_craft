enum MilestoneRewardType {
  discoveryCard,
  avatarFrame,
  unknown,
}

enum DiscoveryCategory {
  scientist,
  phenomenon,
  application,
  technology,
  none,
}

extension DiscoveryCategoryLabel on DiscoveryCategory {
  String get label {
    switch (this) {
      case DiscoveryCategory.scientist:
        return 'Tokoh Sains';
      case DiscoveryCategory.phenomenon:
        return 'Fenomena Sains';
      case DiscoveryCategory.application:
        return 'Penerapan Sains';
      case DiscoveryCategory.technology:
        return 'Teknologi Sains';
      case DiscoveryCategory.none:
        return 'Bingkai Avatar';
    }
  }
}

class CardHighlight {
  const CardHighlight({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final dynamic icon;
}

class MilestoneReward {
  const MilestoneReward({
    required this.id,
    required this.requiredXp,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.unlocked,
    required this.isEquipped,
    this.category = DiscoveryCategory.none,
    this.visualAsset,
    this.unlockedAt,
    this.rarity,
    this.quote,
    this.years,
    this.highlights,
  });

  factory MilestoneReward.fromJson(Map<String, dynamic> json) {
    return MilestoneReward(
      id: (json['reward_key'] ?? json['id'] ?? '').toString(),
      requiredXp: _toInt(json['required_xp']),
      type: _parseType(json['reward_type']),
      category: _parseCategory(json['category']),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      visualAsset: _nullableString(json['visual_asset']),
      unlocked: _toBool(json['unlocked']),
      isEquipped: _toBool(json['is_equipped']),
      unlockedAt: _nullableString(json['unlocked_at']),
      rarity: _nullableString(json['rarity']),
      quote: _nullableString(json['quote']),
      years: _nullableString(json['years']),
    );
  }

  final String id;
  final int requiredXp;
  final MilestoneRewardType type;
  final DiscoveryCategory category;
  final String title;
  final String subtitle;
  final String description;
  final String? visualAsset;
  final bool unlocked;
  final bool isEquipped;
  final String? unlockedAt;
  final String? rarity;
  final String? quote;
  final String? years;
  final List<CardHighlight>? highlights;

  bool get isDiscoveryCard => type == MilestoneRewardType.discoveryCard;
  bool get isAvatarFrame => type == MilestoneRewardType.avatarFrame;

  /// Path gambar visual penemuan (dengan fallback otomatis ke robert_hooke.png untuk setiap discovery card)
  String? get resolvedVisualAsset {
    if (visualAsset != null && visualAsset!.isNotEmpty) return visualAsset;
    if (isDiscoveryCard) {
      return 'assets/images/robert_hooke.png';
    }
    return null;
  }

  String get resolvedRarity {
    if (rarity != null && rarity!.isNotEmpty) return rarity!;
    if (requiredXp >= 500) return 'EPIC';
    if (requiredXp >= 200) return 'RARE';
    return 'COMMON';
  }

  String get resolvedQuote {
    if (quote != null && quote!.isNotEmpty) return quote!;
    if (id.toLowerCase().contains('hooke') || title.toLowerCase().contains('hooke')) {
      return 'Alam bekerja dengan hukum yang teratur.';
    }
    return 'Penemuan ilmiah membuka pintu masa depan.';
  }

  String get resolvedYears {
    if (years != null && years!.isNotEmpty) return years!;
    if (id.toLowerCase().contains('hooke') || title.toLowerCase().contains('hooke')) {
      return '1635 - 1703';
    }
    return '1600 - 1700';
  }

  List<CardHighlight> get resolvedHighlights {
    if (highlights != null && highlights!.isNotEmpty) return highlights!;
    if (id.toLowerCase().contains('hooke') || title.toLowerCase().contains('hooke')) {
      return const <CardHighlight>[
        CardHighlight(
          title: 'HUKUM HOOKE',
          description: 'Menjelaskan hubungan antara gaya dan pertambahan panjang pada pegas.',
          icon: 'tune',
        ),
        CardHighlight(
          title: 'MIKROSKOPI',
          description: 'Meningkatkan desain mikroskop dan mengamati struktur sel gabus (cork).',
          icon: 'biotech',
        ),
        CardHighlight(
          title: 'KARYA TERKENAL',
          description: 'Micrographia (1665) salah satu karya ilmiah paling berpengaruh.',
          icon: 'auto_stories',
        ),
      ];
    }
    return <CardHighlight>[
      CardHighlight(
        title: 'PENEMUAN UTAMA',
        description: description,
        icon: 'science',
      ),
    ];
  }

  static MilestoneRewardType _parseType(dynamic value) {
    switch ((value ?? '').toString()) {
      case 'discovery_card':
        return MilestoneRewardType.discoveryCard;
      case 'avatar_frame':
        return MilestoneRewardType.avatarFrame;
      default:
        return MilestoneRewardType.unknown;
    }
  }

  static DiscoveryCategory _parseCategory(dynamic value) {
    switch ((value ?? '').toString()) {
      case 'scientist':
        return DiscoveryCategory.scientist;
      case 'phenomenon':
        return DiscoveryCategory.phenomenon;
      case 'application':
        return DiscoveryCategory.application;
      case 'technology':
        return DiscoveryCategory.technology;
      default:
        return DiscoveryCategory.none;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return (value ?? '').toString().toLowerCase() == 'true';
  }

  static String? _nullableString(dynamic value) {
    final String text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}
