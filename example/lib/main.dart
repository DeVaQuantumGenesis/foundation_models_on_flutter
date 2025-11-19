import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:foundation_models_on_flutter/foundation_models_on_flutter.dart';

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
  String _response = '';
  bool _isLoading = false;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _foundationModelsOnFlutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final TextEditingController _configController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    _configController.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? config;
    if (_configController.text.isNotEmpty) {
      try {
        config = jsonDecode(_configController.text) as Map<String, dynamic>;
      } catch (e) {
        setState(() {
          _response = 'Invalid JSON config: $e';
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await _foundationModelsOnFlutterPlugin.loadModel(
        'Llama-3-8B-Instruct',
        config: config,
      );
      setState(() {
        _isModelLoaded = true;
        _response = 'Model loaded successfully.';
      });
    } on PlatformException catch (e) {
      setState(() {
        _response = 'Failed to load model: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateResponse() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = 'Generating...';
    });

    try {
      final result = await _foundationModelsOnFlutterPlugin.generateResponse(
        _promptController.text,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Foundation Models Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 20),
              TextField(
                controller: _configController,
                decoration: const InputDecoration(
                  labelText: 'Model Config (JSON, optional)',
                  border: OutlineInputBorder(),
                  hintText: '{"temperature": 0.7}',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _loadModel,
                child: const Text('Load Model'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Enter Prompt',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading || !_isModelLoaded
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
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[200],
                    child: Text(_response),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
