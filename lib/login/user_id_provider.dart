import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_state_provider.dart';
import 'user_id.dart';

final userIdProvider =
    Provider<UserId?>((ref) => ref.watch(authStateProvider).userId);
