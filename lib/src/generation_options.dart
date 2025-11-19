/// Options for controlling the generation behavior of Foundation Models.
class GenerationOptions {
  /// Controls the randomness/creativity of the output.
  ///
  /// Range: 0.0 - 2.0
  /// - Lower values (e.g., 0.5): More focused and deterministic
  /// - Higher values (e.g., 2.0): More creative and diverse
  final double? temperature;

  /// Maximum number of tokens to generate (if supported).
  final int? maxTokens;

  const GenerationOptions({this.temperature, this.maxTokens});

  /// Converts the options to a map for method channel calls.
  Map<String, dynamic> toMap() {
    return {
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'maxTokens': maxTokens,
    };
  }
}
