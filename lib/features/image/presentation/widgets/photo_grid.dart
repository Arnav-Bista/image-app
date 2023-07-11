import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/image/application/controller/photo_list_controller.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_card.dart';
import 'package:images/features/image/presentation/widgets/saved_photo_card.dart';


final loadingProvider = StateProvider((ref) => false);

class PhotoGrid extends ConsumerStatefulWidget {
  const PhotoGrid({super.key, required this.photoSize, required this.itemCount, required this.network});

  final double photoSize;
  final int itemCount;
  final bool network;

  @override
  ConsumerState<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends ConsumerState<PhotoGrid> {

  Future<void> populate() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { 
      ref.read(loadingProvider.notifier).state = true;
      await ref.read(photoListController.notifier).populate(widget.itemCount);
      await ref.read(storedImageController.notifier).getFavourites();
      ref.read(loadingProvider.notifier).state = false;

    });
    print("population");
  }

  bool canUpdate = true;
  late ScrollController sc;

  @override
  void initState() {
    super.initState();
    populate();
    sc = ScrollController()..addListener(_scrollAction);
  }

  void _scrollAction() async {
    if (widget.network && sc.position.extentAfter < 100 && canUpdate) {
      canUpdate = false;
      await ref.read(photoListController.notifier).populate(widget.itemCount);
      canUpdate = true;
    }
  }


  List<Photo> storedData = [];


  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final controller = ref.watch(photoListController);
    // print(controller.toString() + "1231231");
    final storedController = ref.watch(storedImageController);
    if(storedController != null) {
      storedData = storedController.toList();
    }
    // storedData = ref.read(storedImageController)!.toList();
    return isLoading ? const Center(child: CircularProgressIndicator())
        : Scrollbar(
          controller: sc,
          thickness: 8,
          interactive: true,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: widget.photoSize,
            ),
            itemCount: widget.network ? controller.length : storedData.length,
            controller: sc,
            itemBuilder: (contex, index) {
              if (widget.network) {
                return PhotoCard(key: ValueKey(controller[index]), result: controller[index], id: index);
              }
              else {
                return SavedPhotoCard(id: index, result: storedData[index]);
              }
            },
          ),
        );
  }
}
