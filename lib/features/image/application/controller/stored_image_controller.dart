
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/authentication/application/controller/user_controller.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/authentication/infrastructure/repository/user_repository.dart';
import 'package:images/features/image/infrastructure/model/favourites.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/stored_image_repository.dart';

final storedImageController = StateNotifierProvider<StoredImageController, Favourites?>((ref) => StoredImageController(ref: ref));

class StoredImageController extends StateNotifier<Favourites?> {
  StoredImageController({required this.ref}): super(null);

  final StateNotifierProviderRef<StoredImageController, Favourites?> ref;


  IStoredImageRepository _storedImageRepository() => ref.read(storedImageRepository);
  IUserRepository _userRepository() => ref.read(userRepository);

  Future<void> getFavourites() async {
    final result = await ref.read(userController).whenOrNull(data: (data) async {
      return await _storedImageRepository().getFavourites(data!.username);
    });
    // TODO Remove development 
    if(result == null) {
      final newRes = await _storedImageRepository().getFavourites("test");
      if(newRes.isLeft) {
        state = Favourites(data: {});
      }
      else {
        state = newRes.right;
      }
      return;
    }
    if(result.isLeft) {
      print("Empty");
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
      throw Exception("USER IS NULL");
    }
    _storedImageRepository().storeFavourites(user.username, state!);

  }

  void remove(Photo photo) async {
    if(state == null) {
      await getFavourites();
    }
    state!.removePhoto(photo);
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

}
