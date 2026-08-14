import 'dart:io';

import 'package:flutter/services.dart';

class BackgroundServiceBridge {
  static const _channel = MethodChannel(
    'io.github.sanskarin.sonicnest/background_recording',
  );

  Future<void> start() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('start');
  }

  Future<void> stop() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Recorder cleanup must continue even if Android already stopped the service.
    }
  }
}
