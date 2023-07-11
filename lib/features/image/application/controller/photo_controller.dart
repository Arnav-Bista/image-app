import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/get_random_image.dart';

  final photoController = StateNotifierProvider<PhotoController, AsyncValue<Photo?>>((ref) => 
    PhotoController(ref: ref)
  );

  class PhotoController extends StateNotifier<AsyncValue<Photo?>> {
    PhotoController({required this.ref}): super(const AsyncData(null));
    final StateNotifierProviderRef ref;

    IGetRandomImage _getRandomImage() => ref.read(photoRepository);

    Future<void> getRandomPhoto() async {
      state = const AsyncValue.loading();
      final response = await _getRandomImage().getImage();
      if(response.isRight) {
        state = AsyncValue.error(response.right, StackTrace.current);
        return;
      }
      state = AsyncValue.data(response.right);
    }
  }
