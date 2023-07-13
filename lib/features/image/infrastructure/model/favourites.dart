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
    return fav;
  }

  @override
  void write(BinaryWriter writer, Favourites obj) {
    writer.writeMap(obj.data);
  }
}

class Favourites {
  final Map<int, Photo> data;

  Favourites({required this.data});

  List<Photo> toList() {
    return data.values.toList();
  }

  void addPhoto(Photo photo) {
    if(!data.containsKey(photo.id)) {
      data[photo.id] = photo;
    }
  }

  void removePhoto(Photo photo) {
    if(data.containsKey(photo.id)){
      data.remove(photo.id);
    }
  }

  void removeById(int id) {
    if(data.containsKey(id)) {
      data.remove(id);
    }
  }

}
