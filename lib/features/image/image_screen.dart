import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:images/features/image/application/controller/photo_list_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/get_random_image.dart';
import 'package:images/features/image/presentation/widgets/app_bar_buttons.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class ImageScreen extends ConsumerStatefulWidget {
  const ImageScreen({super.key});

  @override
  ConsumerState<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends ConsumerState<ImageScreen> {

  final String _network = "Explore";
  final String _saved = "Favourites";
  bool network = true;
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      network = index == 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    int horizontalItemCount = 3;
    // For Gridview
    double photoSize = MediaQuery.of(context).size.width * 1.0 / horizontalItemCount;
    int verticalItemCount = (MediaQuery.of(context).size.height ~/ photoSize);

    // Actual physical pixels of the phone for better quality

    Photo.photoSize = View.of(context).physicalSize.width ~/ horizontalItemCount;
    Photo.photoSize -= Photo.photoSize % 100;

    final selectionMode = ref.watch(photoSelectionMode);
    final storedImage = ref.read(storedImageController.notifier);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
        actions: [
          selectionMode 
          ? const AppBarButtons()
          : network 
          ? const SizedBox() 
          : ref.read(storedImageController)?.data.isEmpty ?? true
          ? const SizedBox()
          : TextButton(
            onPressed: () => storedImage.removeAll(),
            child: Text(
              "Remove all",
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error
              ),
            ),
          )
        ],
      ),
      body: PhotoGrid(
        itemCount: verticalItemCount * horizontalItemCount, 
        photoSize: photoSize,
        network: network,
      ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.compass_calibration),
              label: _network
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star),
              label: _saved
            )
          ],
          onTap: _onItemTapped,
          currentIndex: selectedIndex,
        ),
        );
  }
}
