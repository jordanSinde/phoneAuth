import 'package:flutter/foundation.dart' show immutable;

@immutable
class Strings {
  static const comment = 'comment';

  static const loading = 'Chargement...';

  static const person = 'personne';
  static const people = 'personnes';
  static const likedThis = 'liked this';

  static const delete = 'Supprimer';
  static const areYouSureYouWantToDeleteThis =
      'Êtes-vous sûre de vouloir supprimer ceci?';

  // log out
  static const logOut = 'Deconnexion';
  static const areYouSureThatYouWantToLogOutOfTheApp =
      'Êtes-vous sûre de vouloir vous déconnecter?';
  static const cancel = 'Annuler';

  const Strings._();
}
