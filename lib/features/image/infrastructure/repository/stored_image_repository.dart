import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/authentication/application/controller/user_controller.dart';
import 'package:images/features/image/infrastructure/model/favourites.dart';


final storedImageRepository = Provider<IStoredImageRepository>((ref) => StoredImageRepository());

abstract class IStoredImageRepository {
  Future<Either<MyError, Favourites>> getFavourites(String username);

  Future<void> storeFavourites(String username, Favourites data);
}


class StoredImageRepository implements IStoredImageRepository {
  
  final user = userController; 
  static Box<Favourites> localBox = Hive.box<Favourites>("userdata");

  @override
    Future<Either<MyError, Favourites>> getFavourites(String username) async {
        Favourites? fetchedData = localBox.get(username);
        if(fetchedData == null) {
          return Left(MyError(errorMessage: "Empty data", location: "getFavourites"));
        }
        else {
          return Right(fetchedData);
        }
    }

  @override
    Future<void> storeFavourites(String username, Favourites data) async {
      await localBox.put(username, data);
    }

}
