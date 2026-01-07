import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection state for Gemini Live API
enum GeminiConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Represents an audio chunk received from Gemini
class GeminiAudioChunk {
  final String mimeType;
  final Uint8List data;
  
  GeminiAudioChunk({required this.mimeType, required this.data});
}

/// Service for real-time bidirectional audio with Gemini Live API
/// 
/// This service handles:
/// - WebSocket connection to Gemini Live API
/// - Sending audio chunks from microphone
/// - Receiving audio responses from Gemini
/// - Automatic VAD (Voice Activity Detection) for turn-taking
/// - Interruption handling
class GeminiLiveService {
  static const String _baseUrl = 
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';
  
  final String _apiKey;
  final String _model;
  final String _voiceName;
  final String? _systemInstruction;
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  // Stream controllers for events
  final _connectionStateController = StreamController<GeminiConnectionState>.broadcast();
  final _audioChunkController = StreamController<GeminiAudioChunk>.broadcast();
  final _modelStartedController = StreamController<void>.broadcast();
  final _modelStoppedController = StreamController<void>.broadcast();
  final _interruptedController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  
  // Setup completion
  Completer<void>? _setupCompleter;
  bool _isSetupComplete = false;
  bool _isModelSpeaking = false;
  
  // Public streams
  Stream<GeminiConnectionState> get connectionState => _connectionStateController.stream;
  Stream<GeminiAudioChunk> get audioChunks => _audioChunkController.stream;
  Stream<void> get onModelStartedSpeaking => _modelStartedController.stream;
  Stream<void> get onModelStoppedSpeaking => _modelStoppedController.stream;
  Stream<void> get onInterrupted => _interruptedController.stream;
  Stream<String> get errors => _errorController.stream;
  
  GeminiConnectionState _currentState = GeminiConnectionState.disconnected;
  GeminiConnectionState get currentState => _currentState;
  bool get isSetupComplete => _isSetupComplete;
  bool get isModelSpeaking => _isModelSpeaking;
  
  GeminiLiveService({
    required String apiKey,
    String model = 'models/gemini-2.5-flash-native-audio-preview-12-2025',
    String voiceName = 'Puck',
    String? systemInstruction,
  })  : _apiKey = apiKey,
        _model = model,
        _voiceName = voiceName,
        _systemInstruction = systemInstruction;
  
  /// Connect to the Gemini Live API
  Future<void> connect() async {
    if (_currentState == GeminiConnectionState.connected ||
        _currentState == GeminiConnectionState.connecting) {
      debugPrint('Gemini: Already connected or connecting');
      return;
    }
    
    _updateState(GeminiConnectionState.connecting);
    _isSetupComplete = false;
    _isModelSpeaking = false;
    _setupCompleter = Completer<void>();
    
    try {
      final uri = Uri.parse('$_baseUrl?key=$_apiKey');
      debugPrint('Gemini: Connecting to ${uri.toString().replaceAll(_apiKey, 'API_KEY_HIDDEN')}');
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for connection
      await _channel!.ready;
      debugPrint('Gemini: WebSocket ready');
      
      // Start listening to messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('Gemini: WebSocket error: $error');
          _errorController.add(error.toString());
          _updateState(GeminiConnectionState.error);
        },
        onDone: () {
          debugPrint('Gemini: WebSocket closed (code: ${_channel?.closeCode}, reason: ${_channel?.closeReason})');
          _updateState(GeminiConnectionState.disconnected);
        },
      );
      
      // Send setup message
      await _sendSetupMessage();
      
      // Wait for setup complete with timeout
      debugPrint('Gemini: Waiting for setup complete...');
      await _setupCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Gemini: Setup timeout');
          throw Exception('Setup timeout');
        },
      );
      
      _updateState(GeminiConnectionState.connected);
      debugPrint('Gemini: Connected and ready!');
    } catch (e) {
      debugPrint('Gemini: Failed to connect: $e');
      _errorController.add(e.toString());
      _updateState(GeminiConnectionState.error);
      rethrow;
    }
  }
  
  /// Disconnect from the Gemini Live API
  Future<void> disconnect() async {
    debugPrint('Gemini: Disconnecting...');
    await _subscription?.cancel();
    _subscription = null;
    
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    
    _isSetupComplete = false;
    _isModelSpeaking = false;
    _updateState(GeminiConnectionState.disconnected);
  }
  
  int _audioChunkCount = 0;
  
  /// Send audio chunk to Gemini
  void sendAudioChunk(Uint8List audioData) {
    if (_currentState != GeminiConnectionState.connected || _channel == null) {
      return;
    }
    
    if (!_isSetupComplete) {
      return;
    }
    
    _audioChunkCount++;
    if (_audioChunkCount % 50 == 1) {
      // Basic amplitude check
      int maxAmp = 0;
      for (int i = 0; i < audioData.length; i += 2) {
        if (i + 1 < audioData.length) {
          int sample = audioData[i] | (audioData[i + 1] << 8);
          if (sample > 32767) sample -= 65536;
          maxAmp = sample.abs() > maxAmp ? sample.abs() : maxAmp;
        }
      }
      debugPrint('Gemini: Sending audio chunk #$_audioChunkCount (${audioData.length} bytes, Peak Amp: $maxAmp)');
    }
    
    final base64Audio = base64Encode(audioData);
    
    // Use 'audio' field (standard for gemini-2.0-flash-live)
    final message = {
      'realtimeInput': {
        'audio': {
          'mimeType': 'audio/pcm;rate=16000',
          'data': base64Audio,
        }
      }
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  /// Signal that audio stream has ended (microphone stopped)
  void sendAudioStreamEnd() {
    if (_currentState != GeminiConnectionState.connected || _channel == null) {
      return;
    }
    
    debugPrint('Gemini: Sending audioStreamEnd');
    
    final message = {
      'realtimeInput': {
        'audioStreamEnd': true,
      }
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  Future<void> _sendSetupMessage() async {
    debugPrint('Gemini: Sending setup message (model: $_model, voice: $_voiceName)');
    
    final setupMessage = {
      'setup': {
        'model': _model,
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': _voiceName,
              }
            }
          }
        },
        // VAD configuration - tuned for noisy environments
        'realtimeInputConfig': {
          'automaticActivityDetection': {
            'disabled': false,
            // Low sensitivity for start = ignores background noise
            'startOfSpeechSensitivity': 'START_SENSITIVITY_LOW',
            // High sensitivity for end = detects silence quickly 
            'endOfSpeechSensitivity': 'END_SENSITIVITY_HIGH',
            'silenceDurationMs': 1000,
          },
          'activityHandling': 'START_OF_ACTIVITY_INTERRUPTS',
        },
        if (_systemInstruction != null)
          'systemInstruction': {
            'parts': [
              {'text': _systemInstruction}
            ]
          }
      }
    };
    
    final jsonMsg = jsonEncode(setupMessage);
    debugPrint('Gemini: Full setup message: $jsonMsg');
    _channel!.sink.add(jsonMsg);
  }
  
  void _handleMessage(dynamic message) {
    try {
      String jsonString;
      if (message is String) {
        jsonString = message;
      } else if (message is List<int>) {
        jsonString = utf8.decode(message);
      } else {
        debugPrint('Gemini: Unknown message type: ${message.runtimeType}');
        return;
      }
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Log ALL messages for debugging
      debugPrint('Gemini: Received: ${jsonString.substring(0, jsonString.length.clamp(0, 500))}');
      
      // Setup complete
      if (data.containsKey('setupComplete')) {
        debugPrint('Gemini: Setup complete!');
        _isSetupComplete = true;
        if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
          _setupCompleter!.complete();
        }
        return;
      }
      
      // Server content (audio response)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        
        // Check if model started speaking
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          
          if (modelTurn.containsKey('parts')) {
            final parts = modelTurn['parts'] as List<dynamic>;
            
            for (final part in parts) {
              if (part is Map<String, dynamic> && part.containsKey('inlineData')) {
                // Audio data from model
                if (!_isModelSpeaking) {
                  _isModelSpeaking = true;
                  debugPrint('Gemini: Model started speaking');
                  _modelStartedController.add(null);
                }
                
                final inlineData = part['inlineData'] as Map<String, dynamic>;
                final mimeType = inlineData['mimeType'] as String? ?? 'audio/pcm;rate=24000';
                final base64Data = inlineData['data'] as String;
                final audioData = base64Decode(base64Data);
                
                _audioChunkController.add(GeminiAudioChunk(
                  mimeType: mimeType,
                  data: audioData,
                ));
              }
            }
          }
        }
        
        // Check if this turn is complete (model finished speaking)
        if (serverContent['turnComplete'] == true) {
          debugPrint('Gemini: Model turn complete');
          _isModelSpeaking = false;
          _modelStoppedController.add(null);
        }
        
        // Check if interrupted by user
        if (serverContent['interrupted'] == true) {
          debugPrint('Gemini: Model was interrupted by user');
          _isModelSpeaking = false;
          _interruptedController.add(null);
        }
      }
      
      // GoAway message (server is closing)
      if (data.containsKey('goAway')) {
        debugPrint('Gemini: Server sending goAway - connection will close soon');
      }
      
      // Error
      if (data.containsKey('error')) {
        final error = data['error'];
        debugPrint('Gemini: Error: $error');
        _errorController.add(error.toString());
      }
      
    } catch (e, stackTrace) {
      debugPrint('Gemini: Error handling message: $e');
      debugPrint('Stack: $stackTrace');
    }
  }
  
  void _updateState(GeminiConnectionState newState) {
    _currentState = newState;
    _connectionStateController.add(newState);
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    await disconnect();
    await _connectionStateController.close();
    await _audioChunkController.close();
    await _modelStartedController.close();
    await _modelStoppedController.close();
    await _interruptedController.close();
    await _errorController.close();
  }
}
