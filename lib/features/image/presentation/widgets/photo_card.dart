import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/application/controller/stored_image_controller.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_details.dart';

class PhotoCard extends ConsumerStatefulWidget {
  const PhotoCard({
    super.key, 
    required this.id, 
    required this.result,
  });

  final int id;
  final Future<Either<MyError, Photo>> result;

  @override
  ConsumerState<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends ConsumerState<PhotoCard> {

  bool isLoading = true;
  bool isError = false;
  late Photo photo;


  Future<void> process() async {
    // setState(() {
    //   isLoading = true;
    // });
    // await Future.delayed(const Duration(milliseconds: 500));
    Either<MyError, Photo> res = await widget.result;
    if(!mounted) {
      return;
    }
    if(res.isRight) {
      photo = res.right;
      if (ref.read(storedImageController)!.data.containsKey(photo.id)){
        photo.favourite = true;
      }
    }
    else{
      isError = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    print("INIT ${widget.id}");
    super.initState();
    process();
  }

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      print("DID CHANGE ${widget.id}");
    }

  @override
  void dispose() {
    super.dispose();
    print("DISPOSE ${widget.id}");
  }

  Future<void> _showDetails(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return PhotoDetails(photo: photo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isError || isLoading 
      ? null 
      : () {
        _showDetails(context);
      },
      child: SizedBox(
               child: Card(
                 child: isLoading 
                 ? const Padding(
                   padding: EdgeInsets.all(25),
                   child: CircularProgressIndicator.adaptive()
                 )
                 : isError ?
                 const Center(
                   child: Icon(Icons.error)
                 )
                 : photo.image
               ),
             ),
    );
  }
}
