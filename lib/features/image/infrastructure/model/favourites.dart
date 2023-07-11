import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:hive/hive.dart';

class FavouritesAdapter extends TypeAdapter<Favourites> {
  @override
  final typeId = 2;

  @override
  Favourites read(BinaryReader reader) {
    Favourites fav = Favourites(
      data: reader.readMap().cast<int,Photo>(),
    );
    fav.length = reader.readInt();
    return fav;
  }

  @override
  void write(BinaryWriter writer, Favourites obj) {
    writer.writeMap(obj.data);
    writer.writeInt(obj.length);
  }
}

class Favourites {
  final Map<int, Photo> data;
  int length = 0;

  Favourites({required this.data});

  List<Photo> toList() {
    return data.values.toList();
  }

  void addPhoto(Photo photo) {
    if(!data.containsKey(photo.id)) {
      data[photo.id] = photo;
      length += 1;
    }
  }

  void removePhoto(Photo photo) {
    if(data.containsKey(photo.id)){
      data.remove(photo.id);
      length -= 1;
    }
  }

}
