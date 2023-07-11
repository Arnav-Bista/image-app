import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final typeId = 1;


  @override
  Photo read(BinaryReader reader) {
    return Photo(
      id: reader.readInt(),
      smallSrc: reader.readString(),
      src: reader.readString(),
      shareSrc: Uri.parse(reader.readString()),
      author: reader.readString(),
      hiImageWidth: reader.readDouble(),
      hiImageHeight: reader.readDouble(),
      favourite: true
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.smallSrc);
    writer.writeString(obj.src);
    writer.writeString(obj.shareSrc.toString());
    writer.writeString(obj.author);
    writer.writeDouble(obj.hiImageWidth);
    writer.writeDouble(obj.hiImageHeight);
  }
}

class Photo {
  final int id;
  final String smallSrc;
  final String src;
  final Uri shareSrc;
  final String author;
  final double hiImageWidth;
  final double hiImageHeight;
  
  bool favourite = false;

  late Image image = _getImage();
  late Image hiImage = _getHiImage();

  static int photoSize = 300;

  final DateFormat df = DateFormat("mm-hh-dd-MM-YYYY");

  Photo({
    required this.id,
    required this.smallSrc,
    required this.src,
    required this.shareSrc,
    required this.author,
    required this.hiImageWidth,
    required this.hiImageHeight,
    required this.favourite
  });

  factory Photo.fromJson(dynamic json) {
    int id = int.parse(json["id"]);
    String smallSrc = "https://picsum.photos/id/$id/$photoSize";
    String src = json["download_url"];
    return Photo(
      id: id,
      smallSrc: smallSrc,
      src: src,
      shareSrc: Uri.parse(json["url"]),
      author: json["author"],
      hiImageWidth: (json["width"] as int).toDouble(),
      hiImageHeight:(json["height"] as int).toDouble(),
      favourite: false
    );
  }

  Image _getImage() {
    return Image.network(smallSrc);
  }

  Image _getHiImage() {
    return Image.network(src);
  }
  
  String getName() {
    String authorName = author.replaceAllMapped(RegExp(" +"), (match) => "_");
    return authorName + df.format(DateTime.now());
  }


}
