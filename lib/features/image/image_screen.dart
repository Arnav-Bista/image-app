import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/get_random_image.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class ImageScreen extends ConsumerStatefulWidget {
  const ImageScreen({super.key});

  @override
  ConsumerState<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends ConsumerState<ImageScreen> {

  final String _network = "View Saved";
  final String _saved = "View Random";
  bool network = true;

  @override
  Widget build(BuildContext context) {
    int horizontalItemCount = 3;
    // For Gridview
    double photoSize = MediaQuery.of(context).size.width * 1.0 / horizontalItemCount;
    int verticalItemCount = (MediaQuery.of(context).size.height ~/ photoSize);

    // Actual physical pixels of the phone for better quality

    Photo.photoSize = View.of(context).physicalSize.width ~/ horizontalItemCount;
    Photo.photoSize -= Photo.photoSize % 100;


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Image View", textAlign: TextAlign.center),
            TextButton(
              onPressed: () {
                setState(() {
                  network = !network;
                });
              },
              child: Text(network ? _network : _saved),
            )
          ],
        ),
      ),
      body: PhotoGrid(
        itemCount: verticalItemCount * horizontalItemCount, 
        photoSize: photoSize,
        network: network,
      ),
      );
  }
}
