import 'foundation_models_on_flutter_platform_interface.dart';
import 'src/model_availability.dart';
import 'src/generation_options.dart';

/// Main class for interacting with Apple's Foundation Models framework.
class FoundationModelsOnFlutter {
  Future<String?> getPlatformVersion() {
    return FoundationModelsOnFlutterPlatform.instance.getPlatformVersion();
  }

  /// Checks the availability of Foundation Models on the device.
  ///
  /// Returns a [ModelAvailability] enum indicating whether the model is
  /// available and ready to use, or the reason it's unavailable.
  ///
  /// Example:
  /// ```dart
  /// final availability = await foundationModels.checkAvailability();
  /// if (availability == ModelAvailability.available) {
  ///   // Proceed with model usage
  /// } else {
  ///   // Handle unavailability
  /// }
  /// ```
  Future<ModelAvailability> checkAvailability() async {
    final result = await FoundationModelsOnFlutterPlatform.instance
        .checkAvailability();
    return ModelAvailability.fromString(result);
  }

  /// Creates a new language model session.
  ///
  /// [instructions] are optional instructions that control the model's behavior.
  /// For example, you can specify the model's role, tone, or constraints.
  ///
  /// Returns a session ID that should be used for subsequent generate calls.
  ///
  /// Example:
  /// ```dart
  /// final sessionId = await foundationModels.createSession(
  ///   instructions: 'You are a helpful cooking assistant. '
  ///       'Provide recipes with 3 ingredients or less.',
  /// );
  /// ```
  Future<String> createSession({String? instructions}) {
    return FoundationModelsOnFlutterPlatform.instance.createSession(
      instructions: instructions,
    );
  }

  /// Generates a response from the model for the given prompt.
  ///
  /// [sessionId] is the ID returned from [createSession].
  /// [prompt] is the input text for the model.
  /// [options] are optional generation parameters like temperature.
  ///
  /// Example:
  /// ```dart
  /// final sessionId = await foundationModels.createSession();
  /// final response = await foundationModels.generateResponse(
  ///   sessionId: sessionId,
  ///   prompt: 'What is the capital of France?',
  ///   options: GenerationOptions(temperature: 0.5),
  /// );
  /// print(response);
  /// ```
  Future<String> generateResponse({
    required String sessionId,
    required String prompt,
    GenerationOptions? options,
  }) {
    return FoundationModelsOnFlutterPlatform.instance.generateResponse(
      sessionId,
      prompt,
      options: options?.toMap(),
    );
  }
}
