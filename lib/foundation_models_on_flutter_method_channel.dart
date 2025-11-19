import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'foundation_models_on_flutter_platform_interface.dart';

/// An implementation of [FoundationModelsOnFlutterPlatform] that uses method channels.
class MethodChannelFoundationModelsOnFlutter
    extends FoundationModelsOnFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('foundation_models_on_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> loadModel(String modelName) async {
    await methodChannel.invokeMethod<void>('loadModel', {
      'modelName': modelName,
    });
  }

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await methodChannel.invokeMethod<String>(
      'generateResponse',
      {'prompt': prompt},
    );
    return response ?? '';
  }
}
