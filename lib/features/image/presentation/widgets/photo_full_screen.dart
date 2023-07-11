import 'package:flutter/material.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';

class PhotoFullScreen extends StatelessWidget {
  const PhotoFullScreen({super.key, required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        child: Hero(
          tag: "fullScreen",
          child: Image(
            image: photo.hiImage.image,
            fit: BoxFit.contain,
            height: double.infinity,
            width: double.infinity,
          )
        )
      )
    );
  }
}
