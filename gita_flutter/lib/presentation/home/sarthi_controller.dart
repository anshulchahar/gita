import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/services/gemini_live_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/pcm_player_service.dart';

/// State for Sarthi voice assistant
class SarthiState {
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;
  final bool isSessionActive;
  final bool isConnecting;
  final String? errorMessage;
  final double soundLevel;

  const SarthiState({
    this.isListening = false,
    this.isProcessing = false,
    this.isSpeaking = false,
    this.isSessionActive = false,
    this.isConnecting = false,
    this.errorMessage,
    this.soundLevel = 0.0,
  });

  SarthiState copyWith({
    bool? isListening,
    bool? isProcessing,
    bool? isSpeaking,
    bool? isSessionActive,
    bool? isConnecting,
    String? errorMessage,
    double? soundLevel,
    bool clearError = false,
  }) {
    return SarthiState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isConnecting: isConnecting ?? this.isConnecting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }
}

/// Provider for Sarthi controller
final sarthiProvider = StateNotifierProvider<SarthiController, SarthiState>((ref) {
  return SarthiController();
});

/// Controller for Sarthi voice assistant
/// Orchestrates Gemini Live API connection, audio recording, and playback
class SarthiController extends StateNotifier<SarthiState> {
  GeminiLiveService? _geminiService;
  final AudioService _audioService = AudioService();
  final PcmPlayerService _pcmPlayer = PcmPlayerService();
  
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _audioChunkSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _turnCompleteSubscription;
  StreamSubscription? _amplitudeSubscription;
  StreamSubscription? _playbackSubscription;
  
  String? _contextText;
  
  SarthiController() : super(const SarthiState()) {
    _initializePlaybackListener();
  }
  
  void _initializePlaybackListener() {
    _playbackSubscription = _pcmPlayer.isPlayingStream.listen((isPlaying) {
      if (mounted) {
        state = state.copyWith(isSpeaking: isPlaying);
      }
    });
  }
  
  /// Initialize a voice assistant session
  /// [contextShlokas] and [contextLesson] provide context for the conversation
  /// [isHomepageMode] when true, uses a system prompt optimized for general Gita guidance
  void initializeSession({
    dynamic contextShlokas, 
    dynamic contextLesson,
    bool isHomepageMode = false,
  }) {
    // Build system instruction from context
    final systemPrompt = isHomepageMode 
        ? _buildHomepageSystemPrompt()
        : _buildSystemPrompt(
            contextShlokas: contextShlokas, 
            contextLesson: contextLesson
          );
    _contextText = systemPrompt;
    
    state = state.copyWith(
      isSessionActive: true,
      clearError: true,
    );
    
    debugPrint('Sarthi session initialized ${isHomepageMode ? "in homepage mode" : "with context"}');
  }
  
  String _buildHomepageSystemPrompt() {
    return '''
You are Sarthi, a wise and compassionate voice assistant for the Bhagavad Gita app.

CRITICAL INSTRUCTION: You MUST answer ALL questions using wisdom, teachings, and principles from the Bhagavad Gita. Every response should be grounded in the Gita's philosophy.

Your approach:
1. Listen to the user's real-life problem, question, or concern
2. Identify the relevant teaching from the Bhagavad Gita that addresses their situation
3. Explain the Gita's wisdom in simple, practical terms
4. When relevant, cite the chapter and verse (e.g., "As Krishna says in Chapter 2, Verse 47...")
5. Offer actionable advice based on these teachings

Key Gita concepts you can draw from:
- Nishkama Karma (action without attachment to results) - Chapter 2, Verse 47
- Equanimity (samatva) in success and failure - Chapter 2, Verse 48
- The three Gunas (Sattva, Rajas, Tamas) - Chapter 14
- Mind control and meditation - Chapter 6
- Devotion and surrender (Bhakti) - Chapter 12
- Knowledge and wisdom (Jnana) - Chapter 4
- The eternal nature of the soul (Atman) - Chapter 2, Verses 11-30
- Doing one's duty (Svadharma) - Chapter 3 and 18

Be warm, encouraging, and explain concepts in simple terms.
Keep your responses concise and conversational since this is a voice interface.
If the user's question is not clearly addressable through Gita wisdom, gently guide them and still provide relevant spiritual insight from the Gita.
''';
  }
  
  String _buildSystemPrompt({dynamic contextShlokas, dynamic contextLesson}) {
    final buffer = StringBuffer();
    buffer.writeln('You are Sarthi, a wise and compassionate voice assistant for the Gita app.');
    buffer.writeln('You help users understand the teachings of the Bhagavad Gita.');
    buffer.writeln('Be warm, encouraging, and explain concepts in simple terms.');
    buffer.writeln('Keep your responses concise and conversational since this is a voice interface.');
    
    if (contextLesson != null) {
      buffer.writeln('\nCurrent lesson context:');
      buffer.writeln(contextLesson.toString());
    }
    
    if (contextShlokas != null) {
      buffer.writeln('\nRelevant shlokas:');
      buffer.writeln(contextShlokas.toString());
    }
    
    return buffer.toString();
  }
  
  /// Toggle listening state
  /// If not listening, start recording and connect to Gemini
  /// If listening, stop recording and wait for response
  Future<void> toggleListening() async {
    if (state.isConnecting) return;
    
    if (state.isListening) {
      await _stopListening();
    } else {
      // If AI is speaking, interrupt it
      if (state.isSpeaking) {
        await _pcmPlayer.interrupt();
      }
      await _startListening();
    }
  }
  
  Future<void> _startListening() async {
    // Get API key
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(errorMessage: 'GEMINI_API_KEY not found in .env');
      debugPrint('Error: GEMINI_API_KEY not found');
      return;
    }
    
    // Check microphone permission
    final hasPermission = await _audioService.hasPermission();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Microphone permission denied');
      return;
    }
    
    state = state.copyWith(isConnecting: true, clearError: true);
    
    try {
      // Initialize Gemini service if needed
      if (_geminiService == null) {
        _geminiService = GeminiLiveService(
          apiKey: apiKey,
          systemInstruction: _contextText,
        );
        _setupGeminiListeners();
      }
      
      // Connect to Gemini
      await _geminiService!.connect();
      
      // Start PCM streaming
      final started = await _audioService.startPcmStreaming(
        onAudioChunk: (Uint8List chunk) {
          _geminiService?.sendAudioChunk(chunk);
        },
      );
      
      if (!started) {
        state = state.copyWith(
          isConnecting: false,
          errorMessage: 'Failed to start audio recording',
        );
        return;
      }
      
      // Start amplitude monitoring for visual feedback
      _amplitudeSubscription = _audioService.onAmplitudeChanged?.listen((amplitude) {
        // Normalize amplitude to 0-1 range
        final normalized = ((amplitude.current + 50) / 50).clamp(0.0, 1.0);
        if (mounted) {
          state = state.copyWith(soundLevel: normalized);
        }
      });
      
      state = state.copyWith(
        isListening: true,
        isConnecting: false,
      );
      
      debugPrint('Sarthi: Started listening');
    } catch (e) {
      debugPrint('Error starting Sarthi: $e');
      state = state.copyWith(
        isConnecting: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> _stopListening() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    
    await _audioService.stopPcmStreaming();
    
    // Signal end of turn to Gemini
    _geminiService?.sendEndOfTurn();
    
    state = state.copyWith(
      isListening: false,
      isProcessing: true,
      soundLevel: 0.0,
    );
    
    debugPrint('Sarthi: Stopped listening, waiting for response');
  }
  
  void _setupGeminiListeners() {
    _connectionSubscription = _geminiService!.connectionState.listen((connState) {
      debugPrint('Gemini connection state: $connState');
      if (connState == GeminiConnectionState.error) {
        state = state.copyWith(
          errorMessage: 'Connection error',
          isConnecting: false,
          isListening: false,
          isProcessing: false,
        );
      } else if (connState == GeminiConnectionState.disconnected) {
        state = state.copyWith(
          isConnecting: false,
          isListening: false,
          isProcessing: false,
        );
      }
    });
    
    _audioChunkSubscription = _geminiService!.audioChunks.listen((chunk) {
      debugPrint('Sarthi: Received audio chunk from Gemini (${chunk.data.length} bytes), queuing for playback');
      // Queue audio for playback
      _pcmPlayer.queueAudio(chunk.data);
      // We're no longer processing, now speaking
      if (state.isProcessing) {
        state = state.copyWith(isProcessing: false);
      }
    });
    
    _errorSubscription = _geminiService!.errors.listen((error) {
      debugPrint('Gemini error: $error');
      state = state.copyWith(errorMessage: error);
    });
    
    _turnCompleteSubscription = _geminiService!.turnComplete.listen((_) {
      debugPrint('Gemini turn complete');
      // The playback listener will update isSpeaking when audio finishes
    });
  }
  
  /// Close the voice assistant session
  Future<void> closeSession() async {
    await _cleanup();
    state = const SarthiState(); // Reset to initial state
    debugPrint('Sarthi session closed');
  }
  
  Future<void> _cleanup() async {
    await _amplitudeSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _audioChunkSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _turnCompleteSubscription?.cancel();
    
    _amplitudeSubscription = null;
    _connectionSubscription = null;
    _audioChunkSubscription = null;
    _errorSubscription = null;
    _turnCompleteSubscription = null;
    
    await _audioService.stopPcmStreaming();
    await _pcmPlayer.stop();
    await _geminiService?.disconnect();
    _geminiService = null;
  }
  
  @override
  void dispose() {
    _cleanup();
    _playbackSubscription?.cancel();
    _audioService.dispose();
    _pcmPlayer.dispose();
    super.dispose();
  }
}
