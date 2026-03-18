import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/di/dependency_injection.dart';
import 'core/services/bootstrap_service.dart';

Future<void> main() async {
  await BootstrapService.initialize();
  AppDependencies.register();

  runApp(const PeerLinkApp());
}
