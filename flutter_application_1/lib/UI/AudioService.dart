import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  late final AudioPlayer _audioPlayer;

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> preloadMusic(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath); // Tải trước file nhạc
      _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      print('Error preloading music: $e');
    }
  }

  void playMusic() {
    _audioPlayer.play();
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping music: $e');
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
