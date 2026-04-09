import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartVisibilityState {
  final bool showMedication;
  final bool showPositives;
  final bool showNegatives;

  ChartVisibilityState({
    this.showMedication = true,
    this.showPositives = true,
    this.showNegatives = true,
  });

  ChartVisibilityState copyWith({
    bool? showMedication,
    bool? showPositives,
    bool? showNegatives,
  }) {
    return ChartVisibilityState(
      showMedication: showMedication ?? this.showMedication,
      showPositives: showPositives ?? this.showPositives,
      showNegatives: showNegatives ?? this.showNegatives,
    );
  }
}

class ChartVisibilityNotifier extends StateNotifier<ChartVisibilityState> {
  ChartVisibilityNotifier() : super(ChartVisibilityState());

  void toggleMedication() {
    state = state.copyWith(showMedication: !state.showMedication);
  }

  void togglePositives() {
    state = state.copyWith(showPositives: !state.showPositives);
  }

  void toggleNegatives() {
    state = state.copyWith(showNegatives: !state.showNegatives);
  }
}

final chartVisibilityProvider = StateNotifierProvider<ChartVisibilityNotifier, ChartVisibilityState>((ref) {
  return ChartVisibilityNotifier();
});
