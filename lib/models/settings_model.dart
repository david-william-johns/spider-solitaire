enum SuitCount { one, two, four }

extension SuitCountExt on SuitCount {
  int get value {
    switch (this) {
      case SuitCount.one:
        return 1;
      case SuitCount.two:
        return 2;
      case SuitCount.four:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case SuitCount.one:
        return '1';
      case SuitCount.two:
        return '2';
      case SuitCount.four:
        return '4';
    }
  }
}

class SettingsModel {
  final SuitCount suitCount;
  final bool darkMode;
  final bool winnableDeals;
  final bool soundEnabled;

  const SettingsModel({
    this.suitCount = SuitCount.one,
    this.darkMode = false,
    this.winnableDeals = true,
    this.soundEnabled = true,
  });

  SettingsModel copyWith({
    SuitCount? suitCount,
    bool? darkMode,
    bool? winnableDeals,
    bool? soundEnabled,
  }) {
    return SettingsModel(
      suitCount: suitCount ?? this.suitCount,
      darkMode: darkMode ?? this.darkMode,
      winnableDeals: winnableDeals ?? this.winnableDeals,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'suitCount': suitCount.index,
        'darkMode': darkMode,
        'winnableDeals': winnableDeals,
        'soundEnabled': soundEnabled,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        suitCount: SuitCount.values[json['suitCount'] as int? ?? 0],
        darkMode: json['darkMode'] as bool? ?? false,
        winnableDeals: json['winnableDeals'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
      );
}
