import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Directory, File;

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Stream for microphone amplitude (for visual feedback)
  Stream<Amplitude>? get onAmplitudeChanged => _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));
  
  // Stream for player state
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<void> startRecording({required Function(String path) onStop}) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) return;

    String filePath;

    if (kIsWeb) {
      // On Web, we don't specify a path, the browser/recorder handles blob creation internally
      // or we pass a specific ID if the library supports it, but typically empty/null for web stream default
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
    await _audioRecorder.dispose();
    await _audioPlayer.dispose();
  }
}
