import 'package:flutter_riverpod/flutter_riverpod.dart';

// Minimal state for Sarthi (placeholder for future implementation)
class SarthiState {
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;
  final bool isSessionActive;
  final String? errorMessage;
  final double soundLevel;

  const SarthiState({
    this.isListening = false,
    this.isProcessing = false,
    this.isSpeaking = false,
    this.isSessionActive = false,
    this.errorMessage,
    this.soundLevel = 0.0,
  });

  SarthiState copyWith({
    bool? isListening,
    bool? isProcessing,
    bool? isSpeaking,
    bool? isSessionActive,
    String? errorMessage,
    double? soundLevel,
  }) {
    return SarthiState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      errorMessage: errorMessage,
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }
}

// Provider
final sarthiProvider = StateNotifierProvider<SarthiController, SarthiState>((ref) {
  return SarthiController();
});

// Placeholder controller - voice assistant to be implemented
class SarthiController extends StateNotifier<SarthiState> {
  SarthiController() : super(const SarthiState());

  // Placeholder - to be implemented
  void initializeSession({dynamic contextShlokas, dynamic contextLesson}) {
    state = state.copyWith(isSessionActive: true);
  }

  // Placeholder - to be implemented
  void toggleListening() {
    // TODO: Implement voice assistant
  }

  void closeSession() {
    state = state.copyWith(isSessionActive: false);
  }
}
