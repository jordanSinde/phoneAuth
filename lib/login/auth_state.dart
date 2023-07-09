import 'package:flutter/foundation.dart' show immutable;

import 'auth_results.dart';
import 'user_id.dart';

@immutable
class AuthState {
  final AuthResult? result;
  final bool isLoading;
  final UserId? userId;

  const AuthState({
    required this.result,
    required this.isLoading,
    required this.userId,
  });

  const AuthState.unkwon()
      : result = null,
        isLoading = false,
        userId = null;
//à quoi sert le fait de copier une instance AuthState
//et switcher uniquement la valeur de isLoading rep :
//si l'Etat de l'authentification est inconnu, isLoading peut etre
//défini à true
  AuthState copiedWithIsloading(bool isLoading) => AuthState(
        result: result,
        isLoading: isLoading,
        userId: userId,
      );

  //toujours se rassurer lorsqu'on travail avec riverpod de créer
  //cette fonction qui vérifie l'égalité de 2 objects

  @override
  bool operator ==(covariant AuthState other) =>
      identical(this, other) ||
      (result == other.result &&
          isLoading == other.isLoading &&
          userId == other.userId);

  @override
  int get hashCode => Object.hash(
        result,
        isLoading,
        userId,
      );
}
