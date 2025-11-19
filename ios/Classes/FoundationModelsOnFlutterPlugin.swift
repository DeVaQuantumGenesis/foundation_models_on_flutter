import Flutter
import UIKit
import FoundationModels

@available(iOS 18.0, *)
public class FoundationModelsOnFlutterPlugin: NSObject, FlutterPlugin {
    private var model: LanguageModel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "foundation_models_on_flutter", binaryMessenger: registrar.messenger())
        let instance = FoundationModelsOnFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 18.0, *) {
            switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            case "loadModel":
                loadModel(call, result: result)
            case "generateResponse":
                generateResponse(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Foundation Models are only available on iOS 18.0 and later.", details: nil))
        }
    }

    private func loadModel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are required", details: nil))
            return
        }
        
        // In a real scenario, we might map modelName to a specific configuration
        // For now, we'll use a default configuration or one derived from the name if possible,
        // but the API usually requires a configuration object.
        // Assuming we want to load a generic model or specific one.
        
        let config = LanguageModelConfiguration()
        
        Task {
            do {
                self.model = try await LanguageModel(configuration: config)
                result(true)
            } catch {
                result(FlutterError(code: "LOAD_FAILED", message: "Failed to load model: \(error.localizedDescription)", details: nil))
            }
        }
    }

    private func generateResponse(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let model = self.model else {
            result(FlutterError(code: "NO_MODEL", message: "No model loaded. Call loadModel first.", details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "prompt is required", details: nil))
            return
        }

        Task {
            do {
                let response = try await model.generate(prompt)
                result(response)
            } catch {
                result(FlutterError(code: "GENERATION_FAILED", message: "Failed to generate response: \(error.localizedDescription)", details: nil))
            }
        }
    }
}
