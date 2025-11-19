import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:foundation_models_on_flutter/foundation_models_on_flutter.dart';
import 'package:foundation_models_on_flutter/src/model_availability.dart';
import 'package:foundation_models_on_flutter/src/generation_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _foundationModelsOnFlutterPlugin = FoundationModelsOnFlutter();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController(
    text: 'You are a helpful assistant. Keep responses concise.',
  );
  String _response = '';
  bool _isLoading = false;
  String? _sessionId;
  ModelAvailability? _availability;
  double _temperature = 1.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkModelAvailability();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _foundationModelsOnFlutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> checkModelAvailability() async {
    try {
      final availability = await _foundationModelsOnFlutterPlugin
          .checkAvailability();
      setState(() {
        _availability = availability;
      });
    } on PlatformException catch (e) {
      setState(() {
        _response = 'Failed to check availability: ${e.message}';
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionId = await _foundationModelsOnFlutterPlugin.createSession(
        instructions: _instructionsController.text.isEmpty
            ? null
            : _instructionsController.text,
      );
      setState(() {
        _sessionId = sessionId;
        _response =
            'Session created successfully. Ready to generate responses.';
      });
    } on PlatformException catch (e) {
      setState(() {
        _response = 'Failed to create session: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateResponse() async {
    if (_promptController.text.isEmpty || _sessionId == null) return;

    setState(() {
      _isLoading = true;
      _response = 'Generating...';
    });

    try {
      final result = await _foundationModelsOnFlutterPlugin.generateResponse(
        sessionId: _sessionId!,
        prompt: _promptController.text,
        options: GenerationOptions(temperature: _temperature),
      );
      setState(() {
        _response = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _response = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getAvailabilityMessage() {
    if (_availability == null) return 'Checking availability...';
    switch (_availability!) {
      case ModelAvailability.available:
        return '✅ Foundation Models are available';
      case ModelAvailability.deviceNotEligible:
        return '❌ Device not eligible for Foundation Models';
      case ModelAvailability.appleIntelligenceNotEnabled:
        return '⚠️ Apple Intelligence not enabled';
      case ModelAvailability.modelNotReady:
        return '⏳ Model is downloading or preparing...';
      case ModelAvailability.unavailable:
        return '❌ Foundation Models unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Foundation Models Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Running on: $_platformVersion'),
                const SizedBox(height: 10),
                Text(
                  _getAvailabilityMessage(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _availability == ModelAvailability.available
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Instructions (optional):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g., You are a cooking expert...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _isLoading || _availability != ModelAvailability.available
                      ? null
                      : _createSession,
                  child: Text(
                    _sessionId == null ? 'Create Session' : 'Recreate Session',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Temperature:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('0.0'),
                    Expanded(
                      child: Slider(
                        value: _temperature,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        label: _temperature.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _temperature = value;
                          });
                        },
                      ),
                    ),
                    const Text('2.0'),
                  ],
                ),
                Text(
                  'Current: ${_temperature.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Prompt:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _promptController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your prompt...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading || _sessionId == null
                      ? null
                      : _generateResponse,
                  child: const Text('Generate Response'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_response),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
