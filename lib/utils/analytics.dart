
enum AnalyticsEvent {
  addMedicationEntry,
  deleteMedicationEntry,
  recordSymptomIntensity,
  toggleMedicationOption,
  addCustomMedicationOption,
  editMedicationOption,
  deleteMedicationOption,
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
    
  }
}