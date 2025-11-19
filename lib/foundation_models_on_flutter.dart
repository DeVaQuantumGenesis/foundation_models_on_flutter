import 'foundation_models_on_flutter_platform_interface.dart';

class FoundationModelsOnFlutter {
  Future<String?> getPlatformVersion() {
    return FoundationModelsOnFlutterPlatform.instance.getPlatformVersion();
  }

  /// Loads a Foundation Model by name.
  ///
  /// [modelName] is the identifier of the model to load (e.g., "Llama-3-8B").
  Future<void> loadModel(String modelName) {
    return FoundationModelsOnFlutterPlatform.instance.loadModel(modelName);
  }

  /// Generates a response from the loaded model.
  ///
  /// [prompt] is the input text for the model.
  Future<String> generateResponse(String prompt) {
    return FoundationModelsOnFlutterPlatform.instance.generateResponse(prompt);
  }
}
