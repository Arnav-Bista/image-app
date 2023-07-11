import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:either_dart/either.dart';
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';


  final userRepository = Provider<IUserRepository>((ref) =>
    UserRepository()
  );


  abstract class IUserRepository {
    Either<MyError, User> getUser(String username);

    Future<void> storeUser(User user);
    
    void setCurrentUser(User user);

    User? getCurrentUser();
  }


class UserRepository implements IUserRepository {

  static Box<User> localBox = Hive.box<User>("users");

  User? currentUser;

  @override
  Either<MyError, User> getUser(String username) {
    User? fetchedUser = localBox.get(username);
    if(fetchedUser == null) {
      return Left(MyError(location: "getUser", errorMessage: "Username or Password incorrect"));
    }
    else {
      return Right(fetchedUser);
    }
  }

  @override
    Future<void> storeUser(User user) async {
      await localBox.put(user.username, user);
    }

  @override
    User? getCurrentUser() {
      return currentUser;
    }   

  @override
    void setCurrentUser(User user) {
      currentUser = user;
    }


}
