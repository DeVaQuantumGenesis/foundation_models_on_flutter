/// Represents the availability status of the Foundation Models on the device.
enum ModelAvailability {
  /// The model is available and ready to use.
  available,

  /// The device is not eligible to run Foundation Models.
  deviceNotEligible,

  /// Apple Intelligence is not enabled on the device.
  appleIntelligenceNotEnabled,

  /// The model is not ready (e.g., downloading or preparing).
  modelNotReady,

  /// The model is unavailable for an unknown reason.
  unavailable;

  /// Creates a [ModelAvailability] from a string value.
  static ModelAvailability fromString(String value) {
    switch (value) {
      case 'available':
        return ModelAvailability.available;
      case 'deviceNotEligible':
        return ModelAvailability.deviceNotEligible;
      case 'appleIntelligenceNotEnabled':
        return ModelAvailability.appleIntelligenceNotEnabled;
      case 'modelNotReady':
        return ModelAvailability.modelNotReady;
      default:
        return ModelAvailability.unavailable;
    }
  }
}
