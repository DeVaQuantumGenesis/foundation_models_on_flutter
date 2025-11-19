import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'foundation_models_on_flutter_method_channel.dart';

abstract class FoundationModelsOnFlutterPlatform extends PlatformInterface {
  /// Constructs a FoundationModelsOnFlutterPlatform.
  FoundationModelsOnFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FoundationModelsOnFlutterPlatform _instance =
      MethodChannelFoundationModelsOnFlutter();

  /// The default instance of [FoundationModelsOnFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFoundationModelsOnFlutter].
  static FoundationModelsOnFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FoundationModelsOnFlutterPlatform] when
  /// they register themselves.
  static set instance(FoundationModelsOnFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> loadModel(String modelName, {Map<String, dynamic>? config}) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  Future<String> generateResponse(String prompt) {
    throw UnimplementedError('generateResponse() has not been implemented.');
  }
}
