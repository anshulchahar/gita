import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Directory;

/// Audio service for recording and playback
/// Extended to support PCM streaming for Gemini Live API
class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  StreamSubscription<Uint8List>? _pcmStreamSubscription;
  bool _isStreamingPcm = false;
  
  // Stream for microphone amplitude (for visual feedback)
  Stream<Amplitude>? get onAmplitudeChanged => _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));
  
  // Stream for player state
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  
  bool get isStreamingPcm => _isStreamingPcm;

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  /// Start recording to a file (legacy mode)
  Future<void> startRecording({required Function(String path) onStop}) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) return;

    String filePath;

    if (kIsWeb) {
      filePath = ''; 
      
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), 
        path: filePath
      );
    } else {
      final Directory tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/${const Uuid().v4()}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), 
        path: filePath
      );
    }
  }

  /// Start streaming PCM audio for Gemini Live API
  /// Records as PCM 16-bit, mono, 16kHz and calls onAudioChunk with raw bytes
  Future<bool> startPcmStreaming({
    required Function(Uint8List chunk) onAudioChunk,
  }) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      debugPrint('AudioService: No microphone permission');
      return false;
    }
    
    if (_isStreamingPcm) {
      debugPrint('AudioService: Already streaming PCM');
      return false;
    }

    try {
      // Start recording as PCM stream
      // The record package can stream audio data
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 256000,
        ),
      );
      
      _isStreamingPcm = true;
      
      _pcmStreamSubscription = stream.listen(
        (data) {
          onAudioChunk(data);
        },
        onError: (error) {
          debugPrint('PCM stream error: $error');
          stopPcmStreaming();
        },
        onDone: () {
          debugPrint('PCM stream done');
          _isStreamingPcm = false;
        },
      );
      
      debugPrint('AudioService: Started PCM streaming at 16kHz');
      return true;
    } catch (e) {
      debugPrint('Failed to start PCM streaming: $e');
      _isStreamingPcm = false;
      return false;
    }
  }
  
  /// Stop PCM streaming
  Future<void> stopPcmStreaming() async {
    if (!_isStreamingPcm) return;
    
    await _pcmStreamSubscription?.cancel();
    _pcmStreamSubscription = null;
    
    try {
      await _audioRecorder.stop();
    } catch (e) {
      debugPrint('Error stopping PCM stream: $e');
    }
    
    _isStreamingPcm = false;
    debugPrint('AudioService: Stopped PCM streaming');
  }

  Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  Future<void> playAudio(String urlOrPath) async {
    if (kIsWeb || urlOrPath.startsWith('http')) {
       await _audioPlayer.play(UrlSource(urlOrPath));
    } else {
       await _audioPlayer.play(DeviceFileSource(urlOrPath));
    }
  }

  Future<void> stopPlayer() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await stopPcmStreaming();
    await _audioRecorder.dispose();
    await _audioPlayer.dispose();
  }
}
