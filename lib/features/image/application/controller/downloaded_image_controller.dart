import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/infrastructure/repository/downloaded_repository.dart';


final downloadedImageController = StateNotifierProvider<DownloadedImageController, List<File>>((ref) => DownloadedImageController(ref: ref));

class DownloadedImageController extends StateNotifier<List<File>> {
  DownloadedImageController({required this.ref}): super([]);

  final StateNotifierProviderRef ref;
  Set<File> deletionArea = HashSet();

  IDownloadedRepository _getDownloadedImage() => ref.read(downloadedRepository);


  Future<void> populate() async {
    final res = await _getDownloadedImage().getPhotos();
    print(res);
    state = res;
  }

  List<File> getData() {
    return state;
  }

  void deleteAll() {
    state = [];
    _getDownloadedImage().deleteAll();
  }

  void addToDeletionArea(File file) {
    deletionArea.add(file);
  }

  void deleteDeletionArea() {
    for(File file in deletionArea) {
      if(file.existsSync()) {
        print("delete");
        file.deleteSync();
      }
    }
    deletionArea.clear();
  }

  void removeFromDeletionArea(File file) {
    deletionArea.remove(file);
  }

  void clearDeletionArea() {
    deletionArea.clear();
  }

  

}
