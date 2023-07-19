
import 'dart:collection';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/authentication/application/controller/user_controller.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/authentication/infrastructure/repository/user_repository.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/infrastructure/model/favourites.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/stored_image_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

final storedImageController = StateNotifierProvider<StoredImageController, Favourites?>((ref) => StoredImageController(ref: ref));

class StoredImageController extends StateNotifier<Favourites?> {
  StoredImageController({required this.ref}): super(null);

  final StateNotifierProviderRef<StoredImageController, Favourites?> ref;

  Set<int> deletionArea = HashSet();

  IStoredImageRepository _storedImageRepository() => ref.read(storedImageRepository);
  IUserRepository _userRepository() => ref.read(userRepository);

  Future<void> getFavourites() async {
    final result = await ref.read(userController).whenOrNull(data: (data) async {
      return await _storedImageRepository().getFavourites(data!.username);
    });
    if(result == null) {
      state = Favourites(data: {});
      return;
    }
    if(result.isLeft) {
      state = Favourites(data: {});
    }
    else {
      state = result.right;
    }
  }
  Future<List<Photo>> getAsList() async {
    final result = await ref.read(userController).whenOrNull(data: (data) async {
      return await _storedImageRepository().getFavourites(data!.username);
    });
    if(result == null || result.isLeft) {
      return [];
    }
    else {
      return result.right.data.values.toList();
    }
  }

  void save() {
    User? user = _userRepository().getCurrentUser();
    if(user == null) {
      print("NULLLL");
      throw Exception("USER IS NULL");
    }
    _storedImageRepository().storeFavourites(user.username, state!);
    ref.read(downloadedImageController.notifier).populate();

  }

  void remove(Photo photo) async {
    if(state == null) {
      await getFavourites();
    }
    state!.removePhoto(photo);
    save();
  }

  void removeById(int id) async {
    if(state == null) {
      await getFavourites();
    }
    state!.removeById(id);
    save();
  }

  void add(Photo photo) async {
    if(state == null) {
      await getFavourites();
    }
    state!.addPhoto(photo);
    save();
  }

  void removeAll() async {
    if(state == null) {
      await getFavourites();
    }
    state = Favourites(data: {});
    save();
  }

  void addToDeletionArea(int id) {
    deletionArea.add(id);
  }

  void deleteDeletionArea() async {
    if(state == null) {
      await getFavourites();
    }
    for(int id in deletionArea) {
      state!.removeById(id);
    }
    clearDeletionArea();
    state = Favourites(data: state!.data);
    save();
  }

  void removeFromDeletionArea(int id) {
    deletionArea.remove(id);
  }

  void clearDeletionArea() {
    deletionArea.clear();
  }

  Future<String> saveImage(Photo photo) async {
    const String path = "/storage/emulated/0/ImageApp/";
    PermissionStatus status = await Permission.storage.request();
    try{
      if(status.isDenied || status.isPermanentlyDenied){
        return "No access, please enable permissions in app settings.";
      }
      await Directory(path).create();
      String imagePath = "$path${photo.getName()}.jpg";
      File file = File(imagePath);
      if(await file.exists()) {
        return saveImage(photo);
      }
      final res = await http.get(Uri.parse(photo.src));
      if(res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
        return "Downloaded!";
      }
      else {
        return "Server Error";
      }

    }
    catch(e) {
      print(e);
      return e.toString();
    }
  }

}
