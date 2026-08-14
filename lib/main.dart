import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'app.dart';
import 'controllers/app_controller.dart';
import 'services/audio_processor.dart';
import 'services/background_service_bridge.dart';
import 'services/external_actions.dart';
import 'services/metadata_store.dart';
import 'services/player_service.dart';
import 'services/recorder_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
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
  await controller.initialize();
  runApp(SonicNestApp(controller: controller));
}
