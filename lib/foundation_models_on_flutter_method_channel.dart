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
  Future<String> checkAvailability() async {
    final availability = await methodChannel.invokeMethod<String>(
      'checkAvailability',
    );
    return availability ?? 'unavailable';
  }

  @override
  Future<String> createSession({String? instructions}) async {
    final sessionId = await methodChannel.invokeMethod<String>(
      'createSession',
      {if (instructions != null) 'instructions': instructions},
    );
    return sessionId ?? '';
  }

  @override
  Future<String> generateResponse(
    String sessionId,
    String prompt, {
    Map<String, dynamic>? options,
  }) async {
    final response = await methodChannel.invokeMethod<String>(
      'generateResponse',
      {
        'sessionId': sessionId,
        'prompt': prompt,
        if (options != null) 'options': options,
      },
    );
    return response ?? '';
  }
}
