import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_results.dart';
import 'auth_state.dart';
import 'authenticator.dart';
import 'user_id.dart';
import 'user_info_storage.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = Authenticator();
  final _userInfoStorage = const UserInfoStorage();
  AuthStateNotifier() : super(const AuthState.unkwon()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsloading(true);
    await _authenticator.logOut();
    state = const AuthState.unkwon();
  }

  Future<void> loginWithGoogle() async {
    state = state.copiedWithIsloading(true);
    final result = await _authenticator.loginWithGoogle();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(
        userId: userId,
      );
      state = AuthState(
        result: result,
        isLoading: false,
        userId: userId,
      );
    }
  }

  Future<void> saveUserInfo({required UserId userId}) {
    return _userInfoStorage.saveUserInfo(
      userId: userId,
      displayName: _authenticator.displayName,
      email: _authenticator.email,
    );
  }
}
