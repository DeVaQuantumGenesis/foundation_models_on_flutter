import Flutter
import UIKit
import FoundationModels

@available(iOS 18.3, *)
public class FoundationModelsOnFlutterPlugin: NSObject, FlutterPlugin {
    private var sessions: [String: LanguageModelSession] = [:]
    private var streamHandlers: [String: ResponseStreamHandler] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "foundation_models_on_flutter",
            binaryMessenger: registrar.messenger()
        )
        let instance = FoundationModelsOnFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 18.3, *) {
            switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            case "checkAvailability":
                checkAvailability(result: result)
            case "createSession":
                createSession(call, result: result)
            case "generateResponse":
                generateResponse(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(FlutterError(
                code: "UNSUPPORTED_VERSION",
                message: "Foundation Models require iOS 18.3 or later.",
                details: nil
            ))
        }
    }
    
    private func checkAvailability(result: @escaping FlutterResult) {
        let model = SystemLanguageModel.default
        
        switch model.availability {
        case .available:
            result("available")
        case .unavailable(.deviceNotEligible):
            result("deviceNotEligible")
        case .unavailable(.appleIntelligenceNotEnabled):
            result("appleIntelligenceNotEnabled")
        case .unavailable(.modelNotReady):
            result("modelNotReady")
        case .unavailable:
            result("unavailable")
        @unknown default:
            result("unavailable")
        }
    }
    
    private func createSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Arguments are required",
                details: nil
            ))
            return
        }
        
        let sessionId = args["sessionId"] as? String ?? UUID().uuidString
        let instructions = args["instructions"] as? String
        
        let session: LanguageModelSession
        if let instructions = instructions {
            session = LanguageModelSession(instructions: instructions)
        } else {
            session = LanguageModelSession()
        }
        
        sessions[sessionId] = session
        result(sessionId)
    }
    
    private func generateResponse(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let sessionId = args["sessionId"] as? String,
              let prompt = args["prompt"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "sessionId and prompt are required",
                details: nil
            ))
            return
        }
        
        guard let session = sessions[sessionId] else {
            result(FlutterError(
                code: "NO_SESSION",
                message: "No session found with ID: \(sessionId). Call createSession first.",
                details: nil
            ))
            return
        }
        
        Task {
            do {
                // Parse generation options if provided
                var options: GenerationOptions?
                if let optionsMap = args["options"] as? [String: Any] {
                    if let temperature = optionsMap["temperature"] as? Double {
                        options = GenerationOptions(temperature: temperature)
                    }
                }
                
                let response: LanguageModelResponse
                if let options = options {
                    response = try await session.respond(to: prompt, options: options)
                } else {
                    response = try await session.respond(to: prompt)
                }
                
                result(response.content)
            } catch {
                result(FlutterError(
                    code: "GENERATION_FAILED",
                    message: "Failed to generate response: \(error.localizedDescription)",
                    details: nil
                ))
            }
        }
    }
}

// Stream handler for streaming responses
@available(iOS 18.3, *)
class ResponseStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var task: Task<Void, Never>?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        guard let args = arguments as? [String: Any],
              let session = args["session"] as? LanguageModelSession,
              let prompt = args["prompt"] as? String else {
            return FlutterError(
                code: "INVALID_ARGUMENT",
                message: "session and prompt are required",
                details: nil
            )
        }
        
        task = Task {
            do {
                for try await chunk in session.respondStream(to: prompt) {
                    events(chunk.content)
                }
                events(FlutterEndOfEventStream)
            } catch {
                events(FlutterError(
                    code: "STREAM_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        task?.cancel()
        eventSink = nil
        return nil
    }
}
