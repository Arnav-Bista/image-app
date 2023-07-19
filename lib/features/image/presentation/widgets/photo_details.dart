import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_full_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class PhotoDetails extends ConsumerStatefulWidget {
  const PhotoDetails({super.key, required this.photo});

  final Photo photo;


  @override
  ConsumerState<PhotoDetails> createState() => _PhotoDetailsState();
}

class _PhotoDetailsState extends ConsumerState<PhotoDetails> {

  Future<void> _launchUrl() async {
    if(!await launchUrl(widget.photo.shareSrc)){
      throw Exception("Couldn't launch url");
    }
  }

  bool isDownloading = false;

  Future<void> save() async {
    setState(() {
      isDownloading = true;
    });
    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            await ref.read(storedImageController.notifier).saveImage(widget.photo)
        ))
      );
    }
    ref.read(downloadedImageController.notifier).populate();
    setState(() {
      isDownloading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    bool isFaviourite = widget.photo.favourite;

    final storedController = ref.watch(storedImageController.notifier);
    if (ref.read(storedImageController)!.data.containsKey(widget.photo.id)){
      widget.photo.favourite = true;
    }

    final double width = MediaQuery.of(context).size.width * 0.8;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return PhotoFullScreen(image: widget.photo.hiImage);
                  }));
                },
                child: 
                SizedBox(
                  height: width / widget.photo.hiImageWidth * widget.photo.hiImageHeight,
                  child: 
                  Stack(
                    alignment: Alignment.topRight,
                    children:[
                      Hero(
                        tag: "fullScreen",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image(
                            image: widget.photo.hiImage.image,
                            fit: BoxFit.fitWidth,
                            loadingBuilder: (context, child, loadingProgress) {
                              if(loadingProgress == null) {
                                return child;
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, exception, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error)
                              );
                            }
                          )
                        ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: 
                          GestureDetector(
                            onTap: () 
                            {
                              setState(() {
                                isFaviourite = !isFaviourite;
                                widget.photo.favourite = !widget.photo.favourite;
                                if(isFaviourite) {
                                  storedController.add(widget.photo);
                                }
                                else {
                                  storedController.remove(widget.photo);
                                }
                              });
                            },
                            child: 
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1.5,
                                    blurRadius: 15,
                                  )
                                ]
                              ),
                              child: 
                              isFaviourite 
                              ? const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              )
                              : const Icon(
                                Icons.star_outline,
                                color: Colors.yellow
                              ),
                        ),
                        ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: 
                          GestureDetector(
                            onTap: () 
                            {
                              Navigator.of(context).pop();
                            },
                            child: 
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1.5,
                                    blurRadius: 15,
                                  )
                                ]
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              )
                            ),
                        ),
                        ),
                        ],
                        ),
                        ),
                        ),
                        Text(widget.photo.author),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(onPressed: _launchUrl, child: const Text("Original")),
                              TextButton(
                                onPressed: isDownloading ? null : save,
                                child: const Text("Download")),
                              TextButton(onPressed: () => Share.share(widget.photo.shareSrc.toString()), child: const Text("Share"))
                            ],
                          ),
                        ),
                        ],
                        ),
                        ),
                        ),
                        );
  }
}

