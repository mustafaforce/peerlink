import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env_keys.dart';
import 'logger_service.dart';

abstract final class BootstrapService {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    log.i('Bootstrap started');

    await dotenv.load(fileName: '.env');

    final String? url = dotenv.env[EnvKeys.supabaseUrl];
    final String? anonKey = dotenv.env[EnvKeys.supabaseAnonKey];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      log.e('Missing Supabase config in .env');
      throw StateError(
        'Missing Supabase configuration. Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    log.i('Supabase initialized');
  }
}
