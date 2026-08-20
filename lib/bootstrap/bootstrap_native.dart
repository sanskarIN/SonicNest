import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import '../app.dart';
import '../controllers/app_controller.dart';
import '../services/audio_processor.dart';
import '../services/background_service_bridge.dart';
import '../services/external_actions.dart';
import '../services/metadata_store.dart';
import '../services/player_service.dart';
import '../services/recorder_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

Future<void> bootstrapSonicNest() async {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId:
          'io.github.sanskarin.sonicnest.channel.playback',
      androidNotificationChannelName: 'SonicNest playback',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
      fastForwardInterval: const Duration(seconds: 10),
      rewindInterval: const Duration(seconds: 10),
    );
  }

  final storage = StorageService();
  final processor = AudioProcessor(storage);
  final controller = AppController(
    storage: storage,
    metadata: MetadataStore(),
    settingsService: SettingsService(),
    recorder: RecorderService(storage, processor, BackgroundServiceBridge()),
    player: PlayerService(),
    processor: processor,
    external: ExternalActions(),
  );

  runApp(SonicNestBootstrap(controller: controller));
}
