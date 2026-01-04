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
class GeminiLiveService {
  static const String _baseUrl = 
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent';
  
  final String _apiKey;
  final String _model;
  final String _voiceName;
  final String? _systemInstruction;
  
  WebSocketChannel? _channel;
  
  // Stream controllers
  final _connectionStateController = StreamController<GeminiConnectionState>.broadcast();
  final _audioChunkController = StreamController<GeminiAudioChunk>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _turnCompleteController = StreamController<void>.broadcast();
  
  // Setup completion
  Completer<void>? _setupCompleter;
  bool _isSetupComplete = false;
  
  // Public streams
  Stream<GeminiConnectionState> get connectionState => _connectionStateController.stream;
  Stream<GeminiAudioChunk> get audioChunks => _audioChunkController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<void> get turnComplete => _turnCompleteController.stream;
  
  GeminiConnectionState _currentState = GeminiConnectionState.disconnected;
  GeminiConnectionState get currentState => _currentState;
  bool get isSetupComplete => _isSetupComplete;
  
  GeminiLiveService({
    required String apiKey,
    String model = 'models/gemini-2.5-flash-native-audio-preview-09-2025',
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
    _setupCompleter = Completer<void>();
    
    try {
      final uri = Uri.parse('$_baseUrl?key=$_apiKey');
      debugPrint('Gemini: Connecting to ${uri.toString().replaceAll(_apiKey, 'API_KEY_HIDDEN')}');
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for connection
      await _channel!.ready;
      debugPrint('Gemini: WebSocket ready');
      
      // Start listening to messages BEFORE sending setup
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('Gemini WebSocket error: $error');
          _errorController.add(error.toString());
          _updateState(GeminiConnectionState.error);
        },
        onDone: () {
          debugPrint('Gemini WebSocket closed');
          _updateState(GeminiConnectionState.disconnected);
        },
      );
      
      // Send setup message
      await _sendSetupMessage();
      
      // Wait for setup complete with timeout
      debugPrint('Gemini: Waiting for setup complete...');
      await _setupCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Gemini: Setup timeout - proceeding anyway');
        },
      );
      
      _updateState(GeminiConnectionState.connected);
      debugPrint('Gemini: Connected and ready');
    } catch (e) {
      debugPrint('Failed to connect to Gemini Live API: $e');
      _errorController.add(e.toString());
      _updateState(GeminiConnectionState.error);
    }
  }
  
  /// Disconnect from the Gemini Live API
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _updateState(GeminiConnectionState.disconnected);
  }
  
  /// Send audio chunk to Gemini
  void sendAudioChunk(Uint8List audioData) {
    if (_currentState != GeminiConnectionState.connected || _channel == null) {
      debugPrint('Gemini: Cannot send audio - not connected (state: $_currentState)');
      return;
    }
    
    if (!_isSetupComplete) {
      debugPrint('Gemini: Cannot send audio - setup not complete');
      return;
    }
    
    final base64Audio = base64Encode(audioData);
    
    final message = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': 'audio/pcm;rate=16000',
            'data': base64Audio,
          }
        ]
      }
    };
    
    _channel!.sink.add(jsonEncode(message));
    // Only log occasionally to avoid spam
    // debugPrint('Gemini: Sent audio chunk (${audioData.length} bytes)');
  }
  
  /// Send end of audio turn signal
  void sendEndOfTurn() {
    if (_currentState != GeminiConnectionState.connected || _channel == null) {
      debugPrint('Gemini: Cannot send end of turn - not connected');
      return;
    }
    
    debugPrint('Gemini: Sending end of turn signal');
    
    final message = {
      'clientContent': {
        'turnComplete': true,
      }
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  Future<void> _sendSetupMessage() async {
    debugPrint('Gemini: Sending setup message with model: $_model, voice: $_voiceName');
    
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
        if (_systemInstruction != null)
          'systemInstruction': {
            'parts': [
              {'text': _systemInstruction}
            ]
          }
      }
    };
    
    final jsonMsg = jsonEncode(setupMessage);
    debugPrint('Gemini: Setup message: ${jsonMsg.substring(0, jsonMsg.length.clamp(0, 200))}...');
    _channel!.sink.add(jsonMsg);
  }
  
  void _handleMessage(dynamic message) {
    try {
      // Handle both String and binary (Uint8List) messages
      // On web, WebSocket can return binary data as Uint8List
      String jsonString;
      if (message is String) {
        jsonString = message;
      } else if (message is List<int>) {
        jsonString = utf8.decode(message);
      } else {
        debugPrint('Gemini: Unknown message type: ${message.runtimeType}');
        return;
      }
      
      debugPrint('Gemini: Received message: ${jsonString.substring(0, jsonString.length.clamp(0, 300))}...');
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Check for setup complete
      if (data.containsKey('setupComplete')) {
        debugPrint('Gemini: Setup complete received!');
        _isSetupComplete = true;
        if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
          _setupCompleter!.complete();
        }
        return;
      }
      
      // Check for server content (audio response)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        debugPrint('Gemini: Received serverContent with keys: ${serverContent.keys}');
        
        // Check for model turn with audio
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          if (modelTurn.containsKey('parts')) {
            final parts = modelTurn['parts'] as List<dynamic>;
            debugPrint('Gemini: modelTurn has ${parts.length} parts');
            for (final part in parts) {
              if (part is Map<String, dynamic> && part.containsKey('inlineData')) {
                final inlineData = part['inlineData'] as Map<String, dynamic>;
                final mimeType = inlineData['mimeType'] as String? ?? 'audio/pcm';
                final base64Data = inlineData['data'] as String;
                final audioData = base64Decode(base64Data);
                
                debugPrint('Gemini: Received audio chunk - mimeType: $mimeType, size: ${audioData.length} bytes');
                
                _audioChunkController.add(GeminiAudioChunk(
                  mimeType: mimeType,
                  data: audioData,
                ));
              } else if (part is Map<String, dynamic> && part.containsKey('text')) {
                debugPrint('Gemini: Received text response: ${part['text']}');
              }
            }
          }
        }
        
        // Check for turn complete
        if (serverContent['turnComplete'] == true) {
          debugPrint('Gemini: Turn complete');
          _turnCompleteController.add(null);
        }
      }
      
      // Check for errors
      if (data.containsKey('error')) {
        final error = data['error'];
        debugPrint('Gemini: Error received: $error');
        _errorController.add(error.toString());
      }
      
      // Check for tool calls (if implemented later)
      if (data.containsKey('toolCall')) {
        debugPrint('Gemini: Tool call received: ${data['toolCall']}');
      }
      
    } catch (e, stackTrace) {
      debugPrint('Error handling Gemini message: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorController.add('Error parsing response: $e');
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
    await _errorController.close();
    await _turnCompleteController.close();
  }
}
