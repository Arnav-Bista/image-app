import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:images/features/authentication/presentation/authentication.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/application/controller/photo_list_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/downloaded_repository.dart';
import 'package:images/features/image/infrastructure/repository/get_random_image.dart';
import 'package:images/features/image/presentation/widgets/app_bar_buttons.dart';
import 'package:images/features/image/presentation/widgets/photo_card.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';
import 'package:images/features/image/presentation/widgets/saved_photo_card.dart';

class ImageScreen extends ConsumerStatefulWidget {
  const ImageScreen({super.key});

  @override
  ConsumerState<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends ConsumerState<ImageScreen> {

  final String _network = "Explore";
  final String _saved = "Favourites";
  final String _downloaded = "Downloaded";
  bool network = true;
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    ref.read(photoSelectionMode.notifier).state = false;
    ref.read(storedImageController.notifier).clearDeletionArea();
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
    final downloadedImage = ref.watch(downloadedImageController.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
        actions: [
          selectionMode 
          ? AppBarButtons(selectedIndex: selectedIndex)
          : network 
          ? TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Authentication()));
            },
            child: Text(
                     "Logout",
                     style: TextStyle(
                       color: Theme.of(context).colorScheme.error
                     ),
                   ),
          ) 
          : ref.read(storedImageController)?.data.isEmpty ?? true
          ? const SizedBox()
          : TextButton(
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text("Remove"),
                  content: const Text("Remove all?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("No")),
                    TextButton(onPressed: () {
                      Navigator.of(context).pop();
                      switch (selectedIndex) {
                        case 1:
                          storedImage.removeAll();
                          break;
                        case 2:
                          downloadedImage.deleteAll();
break;
                        default:
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Removed all"))
                      );
                    }, child: const Text("Yes")),
                  ],
                );
              });
            },
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
          selectedIndex: selectedIndex,
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
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.download),
              label: _downloaded
            )
          ],
          onTap: _onItemTapped,
          currentIndex: selectedIndex,
        ),
        );
  }
}
