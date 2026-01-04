import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

/// Service for playing raw PCM audio received from Gemini Live API
/// PCM audio from Gemini is 24kHz, 16-bit, mono
class PcmPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final List<Uint8List> _audioQueue = [];
  bool _isPlaying = false;
  bool _disposed = false;
  
  // Stream for playback state
  final _playbackStateController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _playbackStateController.stream;
  bool get isPlaying => _isPlaying;
  
  PcmPlayerService() {
    _player.onPlayerComplete.listen((_) {
      _playNext();
    });
  }
  
  /// Queue a PCM audio chunk for playback
  /// The audio is expected to be 24kHz, 16-bit signed, mono
  void queueAudio(Uint8List pcmData) {
    if (_disposed) return;
    
    debugPrint('PcmPlayer: Queuing audio chunk (${pcmData.length} bytes), queue size: ${_audioQueue.length + 1}');
    _audioQueue.add(pcmData);
    
    if (!_isPlaying) {
      _playNext();
    }
  }
  
  /// Stop playback and clear the queue
  Future<void> stop() async {
    _audioQueue.clear();
    await _player.stop();
    _isPlaying = false;
    _playbackStateController.add(false);
  }
  
  /// Interrupt playback (stop and clear queue)
  Future<void> interrupt() async {
    await stop();
  }
  
  Future<void> _playNext() async {
    if (_disposed || _audioQueue.isEmpty) {
      debugPrint('PcmPlayer: Queue empty or disposed, stopping playback');
      _isPlaying = false;
      _playbackStateController.add(false);
      return;
    }
    
    _isPlaying = true;
    _playbackStateController.add(true);
    
    final pcmData = _audioQueue.removeAt(0);
    debugPrint('PcmPlayer: Playing chunk (${pcmData.length} bytes), ${_audioQueue.length} remaining in queue');
    
    try {
      // Convert PCM to WAV for playback
      final wavData = _createWavFromPcm(pcmData, sampleRate: 24000);
      debugPrint('PcmPlayer: Created WAV file (${wavData.length} bytes)');
      
      if (kIsWeb) {
        // For web, use bytes source
        await _player.play(BytesSource(wavData));
      } else {
        // For mobile/desktop, write to temp file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${const Uuid().v4()}.wav');
        await tempFile.writeAsBytes(wavData);
        debugPrint('PcmPlayer: Playing from file: ${tempFile.path}');
        await _player.play(DeviceFileSource(tempFile.path));
        
        // Clean up file after a delay
        Future.delayed(const Duration(seconds: 5), () {
          tempFile.delete().ignore();
        });
      }
    } catch (e, stackTrace) {
      debugPrint('PcmPlayer: Error playing audio: $e');
      debugPrint('PcmPlayer: Stack trace: $stackTrace');
      _playNext(); // Try next chunk
    }
  }
  
  /// Create a WAV file from raw PCM data
  /// WAV header format for PCM audio
  Uint8List _createWavFromPcm(Uint8List pcmData, {required int sampleRate}) {
    final byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
    const blockAlign = 2; // 16-bit mono
    const bitsPerSample = 16;
    const numChannels = 1;
    
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;
    
    final header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);  // 'W'
    header.setUint8(9, 0x41);  // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'
    
    // fmt subchunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    
    // data subchunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataSize, Endian.little);
    
    // Combine header and data
    final wavData = Uint8List(44 + dataSize);
    wavData.setRange(0, 44, header.buffer.asUint8List());
    wavData.setRange(44, 44 + dataSize, pcmData);
    
    return wavData;
  }
  
  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await _player.dispose();
    await _playbackStateController.close();
  }
}
