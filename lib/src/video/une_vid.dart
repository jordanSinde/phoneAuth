// Importer les packages nécessaires
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Créer une classe pour représenter une vidéo
class Video {
  // Définir le constructeur avec les paramètres nommés
  Video({required this.title, required this.description, required this.path});

  // Déclarer les attributs comme des variables finales
  final String title;
  final String description;
  final String path;

  // Créer une méthode pour convertir la vidéo en un document Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'path': path,
    };
  }

  // Créer une méthode pour convertir un document Firestore en une vidéo
  static Video fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Video(
      title: data['title'],
      description: data['description'],
      path: data['path'],
    );
  }
}

// Créer une classe pour afficher la vidéo
class VideoWidget extends StatefulWidget {
  // Définir le constructeur avec la vidéo en paramètre
  const VideoWidget({Key? key, required this.video}) : super(key: key);

  // Déclarer la vidéo comme une variable finale
  final Video video;

  // Créer l'état du widget
  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

// Créer la classe pour gérer l'état du widget
class _VideoWidgetState extends State<VideoWidget> {
  // Déclarer le contrôleur du lecteur vidéo
  late VideoPlayerController _controller;

  // Initialiser le contrôleur avec la vidéo du Storage de Firebase
  @override
  void initState() {
    super.initState();
    // Créer une instance du Storage de Firebase
    FirebaseStorage storage = FirebaseStorage.instance;
    // Obtenir la référence du fichier vidéo à partir du chemin
    Reference ref = storage.ref(widget.video.path);
    // Obtenir l'URL de téléchargement du fichier vidéo
    ref.getDownloadURL().then((url) {
      // Créer le contrôleur du lecteur vidéo avec l'URL de la vidéo
      _controller = VideoPlayerController.networkUrl(url as Uri);
      // Initialiser le contrôleur et notifier l'état du widget
      _controller.initialize().then((_) {
        setState(() {});
      });
      // Jouer la vidéo en boucle
      _controller.setLooping(true);
      _controller.play();
    });
  }

  // Libérer les ressources du contrôleur quand le widget est supprimé
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // Construire le widget avec le lecteur vidéo et le titre et la description de la vidéo
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(widget.video.title),
          Text(widget.video.description),
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
