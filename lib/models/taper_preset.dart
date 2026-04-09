enum TaperPreset {
  linear,
  stepDown,
  custom;

  String get displayName {
    switch (this) {
      case TaperPreset.linear:
        return 'Linear Taper';
      case TaperPreset.stepDown:
        return 'Step Down';
      case TaperPreset.custom:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case TaperPreset.linear:
        return 'Reduce medication by the same amount each day';
      case TaperPreset.stepDown:
        return 'Drop by a set amount each week';
      case TaperPreset.custom:
        return 'Create your own custom schedule';
    }
  }

  String get emoji {
    switch (this) {
      case TaperPreset.linear:
        return '📉';
      case TaperPreset.stepDown:
        return '🪜';
      case TaperPreset.custom:
        return '🎯';
    }
  }
}