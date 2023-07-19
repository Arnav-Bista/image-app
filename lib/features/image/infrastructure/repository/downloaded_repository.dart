
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';


final downloadedRepository = Provider<IDownloadedRepository>((ref) => DownloadedRepository());


abstract class IDownloadedRepository{ 
  Future<List<File>> getPhotos();

  void deleteAll();
}


class DownloadedRepository extends IDownloadedRepository{

  final String path = "/storage/emulated/0/ImageApp/";

  Future<List<File>> getPhotos() async {
    Directory dir = Directory(path);
    List<File> photos = [];
    await dir.list().forEach((element) {
      if(element is File) {
        photos.add(element);
      }
    });
    return photos;
  }

  void deleteAll() {
    Directory dir = Directory(path);
    dir.deleteSync(recursive: true);
    dir.createSync();
  }
}
