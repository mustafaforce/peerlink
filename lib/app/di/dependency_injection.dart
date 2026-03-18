import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository.dart';

abstract final class AppDependencies {
  static late final AuthRepository authRepository;

  static void register() {
    authRepository = AuthRepository(client: Supabase.instance.client);
  }
}
