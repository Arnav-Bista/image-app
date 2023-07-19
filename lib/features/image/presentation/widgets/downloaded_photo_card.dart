import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/infrastructure/repository/downloaded_repository.dart';
import 'package:images/features/image/presentation/widgets/photo_details.dart';
import 'package:images/features/image/presentation/widgets/photo_full_screen.dart';
import 'package:images/features/image/presentation/widgets/photo_grid.dart';

class DownloadedPhotoCard extends ConsumerStatefulWidget {
  const DownloadedPhotoCard({super.key, required this.id, required this.file, required this.photoSize});

  final int id;
  final File file;
  final double photoSize;

  @override
  ConsumerState<DownloadedPhotoCard> createState() => _DownloadedPhotoCardState();
}

class _DownloadedPhotoCardState extends ConsumerState<DownloadedPhotoCard> {

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final selectionMode = ref.watch(photoSelectionMode.notifier);
    final downloadedController = ref.read(downloadedImageController.notifier);

    if(!selectionMode.state) {
      setState(() {
        selected = false;
      });
    }

    final image = Image.file(
      widget.file,
      filterQuality: FilterQuality.none,
      height: widget.photoSize,
      width: widget.photoSize,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print(error);
        return const Center(
          child: Icon(Icons.error)
        );
      },

    );

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
                Hero(
                  tag: "fullScreen",
                  child: image
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
                          downloadedController.addToDeletionArea(widget.file);
                        }
                        else {
                          downloadedController.removeFromDeletionArea(widget.file);
                          if(downloadedController.deletionArea.isEmpty) {
                            selectionMode.state = false;
                          }
                        }
                      }
                      else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoFullScreen(image: image)));
                      }
                    },
                    onLongPress: () {

                      if(!selectionMode.state) {
                        selectionMode.state = true;
                        downloadedController.addToDeletionArea(widget.file);
                        setState(() {
                          selected = true;
                        });
                      }
                    },
                    )
                        )
                        ],
                        ),
                        ),
                        ),
                        ),

                        ) ;
  }
}
