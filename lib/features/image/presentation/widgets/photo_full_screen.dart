import 'package:flutter/material.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';

class PhotoFullScreen extends StatelessWidget {
  const PhotoFullScreen({super.key, required this.image});

  final Image image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        child: Hero(
          tag: "fullScreen",
          child: Image(
            image:image.image,
            fit: BoxFit.contain,
            height: double.infinity,
            width: double.infinity,
          )
        )
      )
    );
  }
}
