
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_details.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class SavedPhotoCard extends ConsumerStatefulWidget {
  const SavedPhotoCard({
    super.key, 
    required this.id, 
    required this.result,
  });

  final int id;
  final Photo result;

  @override
  ConsumerState<SavedPhotoCard> createState() => _SavedPhotoCardState();
}

class _SavedPhotoCardState extends ConsumerState<SavedPhotoCard> {

  Future<void> _showDetails(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return PhotoDetails(photo: widget.result);
    });
  }

  bool selected = false;


  @override
  Widget build(BuildContext context) {
    final selectionMode = ref.watch(photoSelectionMode.notifier);
    final storedImage = ref.read(storedImageController.notifier);

    if(!selectionMode.state) {
      setState(() {
        selected = false;
      });
    }

    return SizedBox(
      child: 
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
        child: 
        Stack(
          children: [
            Image(
            image: widget.result.image.image,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error)
              );
            },
            ),
            selected ? 
            Center(
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey,
                  child: const Icon(Icons.check),
                ),
              )
            )
            : const SizedBox(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if(selectionMode.state){
                    setState(() {
                      selected = !selected;
                    }); 
                    if(selected) {
                      storedImage.addToDeletionArea(widget.result.id);
                    }
                    else {
                      storedImage.removeFromDeletionArea(widget.result.id);
                      if(storedImage.deletionArea.isEmpty) {
                        selectionMode.state = false;
                      }
                    }
                  }
                  else {
                    _showDetails(context);
                  }
                },
                onLongPress: () {
                  if(!selectionMode.state) {
                    selectionMode.state = true;
                    storedImage.addToDeletionArea(widget.result.id);
                    setState(() {
                      selected = true;
                    });
                  }
                  else {
                    _showDetails(context);
                  }
                },
                ),
                ),
                ],
                ),
        ),
                ),
                ),
                );
  }
}
