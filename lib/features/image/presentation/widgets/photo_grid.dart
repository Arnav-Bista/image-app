import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/downloaded_image_controller.dart';
import 'package:images/features/image/application/controller/photo_list_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/infrastructure/repository/downloaded_repository.dart';
import 'package:images/features/image/presentation/widgets/downloaded_photo_card.dart';
import 'package:images/features/image/presentation/widgets/photo_card.dart';
import 'package:images/features/image/presentation/widgets/saved_photo_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final photoSelectionMode = StateProvider((ref) => false);

final loadingProvider = StateProvider((ref) => false);

class PhotoGrid extends ConsumerStatefulWidget {
  const PhotoGrid({super.key, required this.photoSize, required this.itemCount, required this.network, required this.selectedIndex});

  final double photoSize;
  final int itemCount;
  final bool network;
  final int selectedIndex;

  @override
  ConsumerState<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends ConsumerState<PhotoGrid> {

  Future<void> initData() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { 
      ref.read(loadingProvider.notifier).state = true;
      await ref.read(photoListController.notifier).populate(widget.itemCount);
      await ref.read(storedImageController.notifier).getFavourites();
      if(await Permission.storage.request().isGranted) {
      await ref.read(downloadedImageController.notifier).populate();
      } 
      ref.read(loadingProvider.notifier).state = false;

    });
  }


  Future<void> populate() async {
    // await ref.read(photoListController.notifier).populate(widget.itemCount);
    ref.read(photoListController.notifier).populate(widget.itemCount);
  }

  bool canUpdate = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  final RefreshController _refreshController = RefreshController();

  void _onRefresh() async {
    if(widget.network) {
      await ref.read(photoListController.notifier).refresh(widget.itemCount);
    }
    else {
      await ref.read(downloadedImageController.notifier).populate();
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await populate();
    _refreshController.loadComplete();
  }




  List<Photo> storedData = [];
  List<File> downloadedData = [];



  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final remoteController = ref.watch(photoListController);
    final storedController = ref.read(storedImageController);
    final _downloaded = ref.watch(downloadedImageController);
    if(storedController != null) {
      storedData = storedController.toList();
    }
    // storedData = ref.read(storedImageController)!.toList();
    return isLoading ? const Center(child: CircularProgressIndicator())
        : Scrollbar(
          thickness: 8,
          interactive: true,
          child: SmartRefresher(
            controller: _refreshController,
            enablePullUp: widget.network,
            enablePullDown: widget.network || widget.selectedIndex == 2,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: widget.photoSize,
              ),
              itemCount: switch (widget.selectedIndex) {
                0 => remoteController.length,
                1 => storedData.length,
                2 => _downloaded.length,
                _ => 0
              },
              itemBuilder: (contex, index) {
                return switch (widget.selectedIndex) {
                  0 => PhotoCard(key: ValueKey(remoteController[index]), id: index, result: remoteController[index]),
                  1 => SavedPhotoCard(key: ValueKey(storedData[index]), id: index, result: storedData[index]),
                  2 => DownloadedPhotoCard(key: ValueKey(_downloaded[index]), id: index, file: _downloaded[index], photoSize: widget.photoSize),
                  _ => const Placeholder()
                };
              },
            ),
            ),
            );
  }
}
