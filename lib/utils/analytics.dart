import 'package:posthog_flutter/posthog_flutter.dart';

enum AnalyticsEvent {
  addCaffeineEntry,
  deleteCaffeineEntry,
  recordSymptomIntensity,
  toggleCaffeineOption,
  addCustomCaffeineOption,
  editCaffeineOption,
  deleteCaffeineOption,
  toggleSymptom,
  addCustomSymptom,
  editSymptom,
  deleteSymptom,
  toggleChartVisibility,
  navigateDate,
  requestAppReview,
  resetAccount,
  startPlanCreation,
  selectTaperPreset,
  completePlanCreation,
  resetTaperPlan,
  modifyStartingAmount,
  adjustPlanDuration,
  configureStepDown,
  customizeTargets,
  viewActivePlan,
  tapProgressCard,
  starOnGithubFromPopup,
  requestAppReviewFromPopup,
  feedbackPopupShown,
}

class Analytics {
  static void track(AnalyticsEvent event, [Map<String, Object>? metadata]) {
    Posthog().capture(
      eventName: event.name,
      properties: metadata,
    );
  }
}