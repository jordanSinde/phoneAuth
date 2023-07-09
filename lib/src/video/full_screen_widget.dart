import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEnterFullScreen;
  final VoidCallback? onExitFullScreen;

  const FullScreenWidget(
      {Key? key,
      required this.child,
      this.onEnterFullScreen,
      this.onExitFullScreen})
      : super(key: key);

  @override
  State<FullScreenWidget> createState() => _FullScreenWidgetState();

  static void enterFullScreen(BuildContext context,
      {VoidCallback? onEnterFullScreen}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenWidget(
          onEnterFullScreen: onEnterFullScreen,
          child: context.widget,
        ),
      ),
    );
  }

  static void exitFullScreen(BuildContext context,
      {VoidCallback? onExitFullScreen}) {
    Navigator.of(context).pop();
    if (onExitFullScreen != null) {
      onExitFullScreen();
    }
  }
}

class _FullScreenWidgetState extends State<FullScreenWidget> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (widget.onEnterFullScreen != null) {
      widget.onEnterFullScreen!();
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (widget.onExitFullScreen != null) {
      widget.onExitFullScreen!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        if (widget.onExitFullScreen != null) {
          widget.onExitFullScreen!();
        }
        return true;
      },
      child: Scaffold(
        body: widget.child,
      ),
    );
  }
}
