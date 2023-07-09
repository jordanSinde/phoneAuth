import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/strings.dart';
import 'loading_screen_controller.dart';

class LoadingScreen {
  LoadingScreen._sharedInstance(); //ceci est le singleton; ce singleton est un constructeur privée
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  factory LoadingScreen.instance() => _shared;

  /// la classe LoadingScreen n'est pas défini comme immutable car elle ne peut pas l'être
  LoadingScreenController?
      controller; //le fait q'elle soit privée est optionnel

  void show({
    required BuildContext context,
    String text = Strings.loading,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(context: context, text: text);
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController? showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);

    final state = Overlay.of(context);

    // ignore: unnecessary_null_comparison
    if (state == null) {
      return null;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox
        .size; //le but c'est de redimensioner le popup/ l'overlay en fonction de la dimension de l'écran
    //en utilisant cette size on peut proportionellement régler la hauteur et la largeur de notre loadingScreen
    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                // largeurMax = 80% de la largeur de l'écran
                maxWidth: size.width * 0.8,
                //longeurMax = 80% de la longeur de l'écran
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 16,
                      ),
                      StreamBuilder(
                          stream: textController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data as String,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black),
                              );
                            } else {
                              return Container();
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        textController.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        textController.add(text);
        return true;
      },
    );
  }
}
