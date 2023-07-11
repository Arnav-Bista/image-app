import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_full_screen.dart';
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
      throw Exception("Couldnt launch url");
    }
  }

  bool isDownloading = false;

  Future<void> save() async {
    setState(() {
      isDownloading = true;
    });
    String message = "";
    final imagePath = "${Directory.systemTemp.path}/${widget.photo.getName()}";
    final file = File(imagePath);
    try{

      if(!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }
      if(await Gal.hasAccess()) {
        final res = await http.get(Uri.parse(widget.photo.src));
        if(res.statusCode == 200) {
          await file.writeAsBytes(res.bodyBytes);
          Gal.putImage(imagePath);
          message = "Downloaded!";
        }
        else {
          message = "Network Error";
        }
      }
    }
    catch(e) {
      message = e.toString();
    }
    setState(() {
      isDownloading = false;
    });

    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    bool isFaviourite = widget.photo.favourite;

    final storedController = ref.watch(storedImageController.notifier);

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
                    return PhotoFullScreen(photo: widget.photo);
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
                          )
                        ),
                      ),
                      Positioned(
                        right: 10,
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
                      )
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
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Back")) 
                          ],
                          ),
                          ),
                          ),
                          );
  }
}

