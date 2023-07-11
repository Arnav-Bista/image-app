
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:images/features/image/presentation/widgets/photo_details.dart';

class SavedPhotoCard extends StatefulWidget {
  const SavedPhotoCard({
    super.key, 
    required this.id, 
    required this.result,
  });

  final int id;
  final Photo result;

  @override
  State<SavedPhotoCard> createState() => _SavedPhotoCardState();
}

class _SavedPhotoCardState extends State<SavedPhotoCard> {

  Future<void> _showDetails(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return PhotoDetails(photo: widget.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDetails(context);
      },
      child: SizedBox(
               child: Card(
                 child: widget.result.image
               ),
             ),
    );
  }
}
