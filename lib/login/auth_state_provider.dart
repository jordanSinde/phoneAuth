import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_state.dart';
import 'auth_state_notifier.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(),
);
