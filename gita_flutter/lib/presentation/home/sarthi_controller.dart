import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/services/gemini_live_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/pcm_player_service.dart';

/// Voice assistant states
enum VoiceAssistantState {
  /// Not active, button shows "Start"
  inactive,
  /// Connecting to Gemini API
  connecting,
  /// Recording user audio, waiting for speech
  listening,
  /// Model is generating/speaking response
  responding,
  /// Model done speaking, waiting for user to speak or timeout
  waitingForUser,
}

/// State for Sarthi voice assistant
class SarthiState {
  final VoiceAssistantState state;
  final String? errorMessage;
  final double soundLevel;

  const SarthiState({
    this.state = VoiceAssistantState.inactive,
    this.errorMessage,
    this.soundLevel = 0.0,
  });

  SarthiState copyWith({
    VoiceAssistantState? state,
    String? errorMessage,
    double? soundLevel,
    bool clearError = false,
  }) {
    return SarthiState(
      state: state ?? this.state,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }

  // Convenience getters for UI
  bool get isActive => state != VoiceAssistantState.inactive;
  bool get isListening => state == VoiceAssistantState.listening;
  bool get isResponding => state == VoiceAssistantState.responding;
  bool get isConnecting => state == VoiceAssistantState.connecting;
  bool get isWaitingForUser => state == VoiceAssistantState.waitingForUser;
}

/// Provider for Sarthi controller
final sarthiProvider = StateNotifierProvider<SarthiController, SarthiState>((ref) {
  return SarthiController();
});

/// Controller for Sarthi voice assistant
/// 
/// Implements the voice assistant logic:
/// - Single button to activate/deactivate
/// - Automatic listening when active
/// - VAD-based turn detection (model responds when user stops)
/// - Interruption support (user speaking stops model)
/// - Auto-deactivation after model finishes and user doesn't respond
class SarthiController extends StateNotifier<SarthiState> {
  GeminiLiveService? _geminiService;
  final AudioService _audioService = AudioService();
  final PcmPlayerService _pcmPlayer = PcmPlayerService();
  
  // Subscriptions
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _audioChunkSubscription;
  StreamSubscription? _modelStartedSubscription;
  StreamSubscription? _modelStoppedSubscription;
  StreamSubscription? _interruptedSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _amplitudeSubscription;
  StreamSubscription? _playbackSubscription;
  
  // Auto-deactivation timer
  Timer? _inactivityTimer;
  static const Duration _inactivityTimeout = Duration(seconds: 3);
  
  // Context for system instruction
  String? _contextText;
  
  SarthiController() : super(const SarthiState()) {
    _initializePlaybackListener();
  }
  
  void _initializePlaybackListener() {
    _playbackSubscription = _pcmPlayer.isPlayingStream.listen((isPlaying) {
      // Playback state is handled by model events now
    });
  }
  
  /// Initialize context for the voice assistant
  void initializeSession({
    dynamic contextShlokas, 
    dynamic contextLesson,
    bool isHomepageMode = false,
  }) {
    _contextText = isHomepageMode 
        ? _buildHomepageSystemPrompt()
        : _buildSystemPrompt(
            contextShlokas: contextShlokas, 
            contextLesson: contextLesson
          );
    debugPrint('Sarthi: Session context initialized');
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
  
  /// Toggle the voice assistant on/off
  /// This is the ONLY user action - everything else is automatic
  Future<void> toggleSession() async {
    if (state.state == VoiceAssistantState.inactive) {
      await _activate();
    } else {
      await _deactivate();
    }
  }
  
  /// Activate the voice assistant
  Future<void> _activate() async {
    debugPrint('Sarthi: Activating...');
    
    // Get API key
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(errorMessage: 'GEMINI_API_KEY not found in .env');
      debugPrint('Sarthi: ERROR - GEMINI_API_KEY not found');
      return;
    }
    
    // Check microphone permission
    final hasPermission = await _audioService.hasPermission();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Microphone permission denied');
      debugPrint('Sarthi: ERROR - Microphone permission denied');
      return;
    }
    
    state = state.copyWith(state: VoiceAssistantState.connecting, clearError: true);
    
    try {
      // Create Gemini service
      _geminiService = GeminiLiveService(
        apiKey: apiKey,
        systemInstruction: _contextText,
      );
      _setupGeminiListeners();
      
      // Connect to Gemini
      await _geminiService!.connect();
      
      // Start recording immediately
      await _startRecording();
      
      state = state.copyWith(state: VoiceAssistantState.listening);
      debugPrint('Sarthi: Active and listening');
      
    } catch (e) {
      debugPrint('Sarthi: ERROR activating: $e');
      state = state.copyWith(
        state: VoiceAssistantState.inactive,
        errorMessage: e.toString(),
      );
      await _cleanup();
    }
  }
  
  /// Deactivate the voice assistant
  Future<void> _deactivate() async {
    debugPrint('Sarthi: Deactivating...');
    _cancelInactivityTimer();
    await _cleanup();
    state = const SarthiState(); // Reset to initial state
    debugPrint('Sarthi: Deactivated');
  }
  
  /// Start recording audio and sending to Gemini
  Future<void> _startRecording() async {
    final started = await _audioService.startPcmStreaming(
      onAudioChunk: (Uint8List chunk) {
        _geminiService?.sendAudioChunk(chunk);
      },
    );
    
    if (!started) {
      throw Exception('Failed to start audio recording');
    }
    
    // Monitor amplitude for visual feedback
    _amplitudeSubscription = _audioService.onAmplitudeChanged?.listen((amplitude) {
      final normalized = ((amplitude.current + 50) / 50).clamp(0.0, 1.0);
      if (mounted) {
        state = state.copyWith(soundLevel: normalized);
      }
    });
    
    debugPrint('Sarthi: Recording started');
  }
  
  /// Stop recording audio
  Future<void> _stopRecording() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    await _audioService.stopPcmStreaming();
    state = state.copyWith(soundLevel: 0.0);
    debugPrint('Sarthi: Recording stopped');
  }
  
  void _setupGeminiListeners() {
    // Connection state
    _connectionSubscription = _geminiService!.connectionState.listen((connState) {
      debugPrint('Sarthi: Gemini connection state: $connState');
      if (connState == GeminiConnectionState.error ||
          connState == GeminiConnectionState.disconnected) {
        if (state.state != VoiceAssistantState.inactive) {
          _deactivate();
        }
      }
    });
    
    // Audio chunks from Gemini (model speaking)
    _audioChunkSubscription = _geminiService!.audioChunks.listen((chunk) {
      _pcmPlayer.queueAudio(chunk.data);
    });
    
    // Model started speaking
    _modelStartedSubscription = _geminiService!.onModelStartedSpeaking.listen((_) {
      debugPrint('Sarthi: Model started speaking');
      _cancelInactivityTimer();
      state = state.copyWith(state: VoiceAssistantState.responding);
    });
    
    // Model stopped speaking (turn complete)
    _modelStoppedSubscription = _geminiService!.onModelStoppedSpeaking.listen((_) {
      debugPrint('Sarthi: Model stopped speaking');
      state = state.copyWith(state: VoiceAssistantState.waitingForUser);
      _startInactivityTimer();
    });
    
    // User interrupted model
    _interruptedSubscription = _geminiService!.onInterrupted.listen((_) {
      debugPrint('Sarthi: User interrupted model');
      _pcmPlayer.interrupt();
      _cancelInactivityTimer();
      state = state.copyWith(state: VoiceAssistantState.listening);
    });
    
    // Errors
    _errorSubscription = _geminiService!.errors.listen((error) {
      debugPrint('Sarthi: Gemini error: $error');
      state = state.copyWith(errorMessage: error);
    });
  }
  
  /// Start inactivity timer for auto-deactivation
  void _startInactivityTimer() {
    _cancelInactivityTimer();
    debugPrint('Sarthi: Starting inactivity timer (${_inactivityTimeout.inSeconds}s)');
    _inactivityTimer = Timer(_inactivityTimeout, () {
      debugPrint('Sarthi: Inactivity timeout - auto-deactivating');
      _deactivate();
    });
  }
  
  /// Cancel inactivity timer
  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }
  
  /// Clean up all resources
  Future<void> _cleanup() async {
    _cancelInactivityTimer();
    
    await _connectionSubscription?.cancel();
    await _audioChunkSubscription?.cancel();
    await _modelStartedSubscription?.cancel();
    await _modelStoppedSubscription?.cancel();
    await _interruptedSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    
    _connectionSubscription = null;
    _audioChunkSubscription = null;
    _modelStartedSubscription = null;
    _modelStoppedSubscription = null;
    _interruptedSubscription = null;
    _errorSubscription = null;
    _amplitudeSubscription = null;
    
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
