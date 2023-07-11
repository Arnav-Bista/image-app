import 'package:flutter/material.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';

class SelectedImage extends StatelessWidget {
  const SelectedImage({super.key, required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              photo.hiImage,
              Text(photo.author)
            ],
          ),
        ),
      ),
    );
  }
}
