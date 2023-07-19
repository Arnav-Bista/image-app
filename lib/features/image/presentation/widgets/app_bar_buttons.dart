import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class AppBarButtons extends ConsumerWidget{
  const AppBarButtons({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeController = ref.read(storedImageController.notifier);
    final selectionController = ref.read(photoSelectionMode.notifier);
    final downloadedController = ref.read(downloadedImageController.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          child: Text(
            "Remove",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error
            ),
          ),
          onPressed: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: const Text("Remove"),
                content: const Text("Remove selected?"),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("No")),
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                    final length = switch (selectedIndex) {
                      2 => downloadedController.deletionArea.length,
                      _ => storeController.deletionArea.length,
                    };
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Removed $length pictures"))
                    );
                    switch (selectedIndex) {
                      case 2:
                        downloadedController.deleteDeletionArea();
                        break;
                      default:
                        storeController.deleteDeletionArea();
                    }
                    selectionController.state = false;
                  }, child: const Text("Yes")),
                ],
                );
            });
          },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              switch (selectedIndex) {
                case 2:
                  downloadedController.clearDeletionArea();
                  break;
                default:
                  storeController.clearDeletionArea();
              }
              selectionController.state = false;
            },
          ),
          ],
          );
  }
}
