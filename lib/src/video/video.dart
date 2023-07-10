import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String url;
  final String description;
  final String image;

  Video({
    required this.id,
    required this.url,
    required this.description,
    required this.image,
  });

  // Créer une méthode pour convertir un document Firestore en une vidéo
  static Video fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Video(
      id: data['id'],
      description: data['description'],
      url: data['url'],
      image: data['image'],
    );
  }

  // Créer une méthode pour convertir la vidéo en un document Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'description': description,
      'url': url,
      'image': image,
    };
  }
}
