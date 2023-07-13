import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class AppBarButtons extends ConsumerWidget{
  const AppBarButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeController = ref.read(storedImageController.notifier);
    final selectionController = ref.read(photoSelectionMode.notifier);
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
                    storeController.deleteDeletionArea();
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
              storeController.clearDeletionArea();
              selectionController.state = false;
            },
          )
              ],
              );
  }
}
