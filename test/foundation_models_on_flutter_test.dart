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
  Future<String> checkAvailability() => Future.value('available');

  @override
  Future<String> createSession({String? instructions}) =>
      Future.value('test-session-id');

  @override
  Future<String> generateResponse(
    String sessionId,
    String prompt, {
    Map<String, dynamic>? options,
  }) => Future.value('Mock response');
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

  test('createSession and generateResponse', () async {
    FoundationModelsOnFlutter foundationModelsOnFlutterPlugin =
        FoundationModelsOnFlutter();
    MockFoundationModelsOnFlutterPlatform fakePlatform =
        MockFoundationModelsOnFlutterPlatform();
    FoundationModelsOnFlutterPlatform.instance = fakePlatform;

    final sessionId = await foundationModelsOnFlutterPlugin.createSession();
    expect(sessionId, 'test-session-id');

    expect(
      await foundationModelsOnFlutterPlugin.generateResponse(
        sessionId: sessionId,
        prompt: 'hello',
      ),
      'Mock response',
    );
  });
}
