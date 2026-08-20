import 'package:flutter/widgets.dart';

import '../main_web.dart' as web_app;

Future<void> bootstrapSonicNest() async {
  WidgetsFlutterBinding.ensureInitialized();
  web_app.runSonicNestWeb();
}
