# foundation_models_on_flutter

A Flutter plugin for integrating Apple's Foundation Models (available on iOS 26+).
This plugin allows you to run powerful on-device machine learning models directly within your Flutter application using the native Apple APIs.

## Features

*   **Native Integration**: Seamlessly access Apple's Foundation Models framework.
*   **Model Loading**: Load specific models by name with optional configuration.
*   **Text Generation**: Generate text responses from prompts using the loaded model.
*   **iOS 26+ Support**: Designed for the latest iOS capabilities.

## Getting started

This plugin requires **iOS 26.0** or higher.

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  foundation_models_on_flutter: ^0.0.1
```

## Usage

Import the package and use the `FoundationModelsOnFlutter` class to interact with the models.

```dart
import 'package:foundation_models_on_flutter/foundation_models_on_flutter.dart';

void main() async {
  final foundationModels = FoundationModelsOnFlutter();

  // 1. Check Platform Version (Optional)
  final version = await foundationModels.getPlatformVersion();
  print('Running on: $version');

  // 2. Load a Model
  // Replace 'Llama-3-8B' with the actual model identifier you intend to use.
  try {
    await foundationModels.loadModel(
      'Llama-3-8B',
      config: {'temperature': 0.7},
    );
    print('Model loaded successfully');
  } catch (e) {
    print('Failed to load model: $e');
    return;
  }

  // 3. Generate a Response
  try {
    final response = await foundationModels.generateResponse('Tell me a joke about Flutter.');
    print('Response: $response');
  } catch (e) {
    print('Failed to generate response: $e');
  }
}
```

## Additional information

*   This plugin is a wrapper around Apple's native Foundation Models API.
*   Ensure your testing device or simulator is running iOS 26 or later.
*   For more details on available models and configurations, refer to Apple's official documentation.
