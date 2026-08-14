import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService extends ChangeNotifier {
  PlayerService() {
    _subscriptions.add(_player.positionStream.listen((value) {
      position = value;
      notifyListeners();
    }));
    _subscriptions.add(_player.durationStream.listen((value) {
      duration = value ?? Duration.zero;
      notifyListeners();
    }));
    _subscriptions.add(_player.playerStateStream.listen((value) {
      isPlaying = value.playing;
      isLoading = value.processingState == ProcessingState.loading ||
          value.processingState == ProcessingState.buffering;
      if (value.processingState == ProcessingState.completed &&
          _player.loopMode == LoopMode.off) {
        isPlaying = false;
      }
      notifyListeners();
    }));
    _subscriptions.add(_player.errorStream.listen((error) {
      lastError = error.message;
      notifyListeners();
    }));
  }

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  String? loadedPath;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;
  String? lastError;

  double get speed => _player.speed;
  double get volume => _player.volume;
  bool get looping => _player.loopMode == LoopMode.one;
  bool get skipSilence => _player.skipSilenceEnabled;

  Future<Duration> probeDuration(String path) async {
    final probe = AudioPlayer();
    try {
      return await probe.setFilePath(path) ?? Duration.zero;
    } finally {
      await probe.dispose();
    }
  }

  Future<void> load(String path, {double speed = 1, bool skipSilence = false}) async {
    if (!await File(path).exists()) throw const FileSystemException('Audio file does not exist.');
    lastError = null;
    await _player.setFilePath(path);
    loadedPath = path;
    await _player.setSpeed(speed.clamp(.5, 2.0).toDouble());
    try {
      await _player.setSkipSilenceEnabled(skipSilence);
    } catch (_) {
      // Skip-silence is only implemented on selected platforms.
    }
    notifyListeners();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  Future<void> seek(Duration target) async {
    final bounded = target < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && target > duration ? duration : target);
    await _player.seek(bounded);
  }

  Future<void> jump(Duration delta) => seek(position + delta);

  Future<void> setSpeed(double value) async {
    await _player.setSpeed(value.clamp(.5, 2.0).toDouble());
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(value.clamp(0.0, 1.0).toDouble());
    notifyListeners();
  }

  Future<void> setLooping(bool enabled) async {
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> setSkipSilence(bool enabled) async {
    try {
      await _player.setSkipSilenceEnabled(enabled);
      notifyListeners();
    } catch (_) {
      throw UnsupportedError('Silence skipping is not available on this playback backend.');
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
