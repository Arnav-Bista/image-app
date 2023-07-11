import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/get_random_image.dart';

final photoListController = StateNotifierProvider<PhotoListController, List<Future<Either<MyError, Photo>>>> ((ref) => PhotoListController(ref: ref));

class PhotoListController extends StateNotifier<List<Future<Either<MyError, Photo>>>> {
  PhotoListController({required this.ref}): super([]);

  final StateNotifierProviderRef ref;

  IGetRandomImage _getRandomImage() => ref.read(photoRepository);

  Future<void> populate(int items) async {
    Future<Either<MyError, Photo>> result;
    for(int i = 0; i < items; i++) {
      result = _getRandomImage().getImage();
      state.add(result);
    }
    state = state.toList();
  }

  Future<void> refresh(int items) async {
    state = [];
    populate(items);
  }
}
