import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_models_on_flutter/foundation_models_on_flutter.dart';
import 'package:foundation_models_on_flutter/foundation_models_on_flutter_platform_interface.dart';
import 'package:foundation_models_on_flutter/foundation_models_on_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFoundationModelsOnFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FoundationModelsOnFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> loadModel(String modelName) => Future.value();

  @override
  Future<String> generateResponse(String prompt) =>
      Future.value('Mock response');
}

void main() {
  final FoundationModelsOnFlutterPlatform initialPlatform =
      FoundationModelsOnFlutterPlatform.instance;

  test('$MethodChannelFoundationModelsOnFlutter is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFoundationModelsOnFlutter>(),
    );
  });

  test('getPlatformVersion', () async {
    FoundationModelsOnFlutter foundationModelsOnFlutterPlugin =
        FoundationModelsOnFlutter();
    MockFoundationModelsOnFlutterPlatform fakePlatform =
        MockFoundationModelsOnFlutterPlatform();
    FoundationModelsOnFlutterPlatform.instance = fakePlatform;

    expect(await foundationModelsOnFlutterPlugin.getPlatformVersion(), '42');
  });

  test('loadModel and generateResponse', () async {
    FoundationModelsOnFlutter foundationModelsOnFlutterPlugin =
        FoundationModelsOnFlutter();
    MockFoundationModelsOnFlutterPlatform fakePlatform =
        MockFoundationModelsOnFlutterPlatform();
    FoundationModelsOnFlutterPlatform.instance = fakePlatform;

    await foundationModelsOnFlutterPlugin.loadModel('test-model');
    expect(
      await foundationModelsOnFlutterPlugin.generateResponse('hello'),
      'Mock response',
    );
  });
}
