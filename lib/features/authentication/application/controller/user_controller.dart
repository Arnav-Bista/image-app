import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:images/core/widgets/my_error.dart';


import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/authentication/infrastructure/repository/user_repository.dart';

final userController = StateNotifierProvider<UserController, AsyncValue<User?>>((ref) {
  return UserController(ref: ref);
});

class UserController extends StateNotifier<AsyncValue<User?>> {
  UserController({required this.ref}): super(const AsyncData(null));

  final StateNotifierProviderRef ref;

  IUserRepository _userRepository() => ref.read(userRepository);

  Future<void> storeUser(String username, String rawPassword) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));

    if(await userExists(username)) {
      state = AsyncValue.error(MyError(errorMessage: "Username already exists. Try logging in.", location: "storeUser"), StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    User user = User.createUser(username, rawPassword);
    await _userRepository().storeUser(user);
    state = const AsyncValue.data(null);
  }

  Future<bool> userExists(String username) async {
    final result = _userRepository().getUser(username);
    return result.isLeft;
  }


  Future<void> authenticateUser(String username, String rawPassword) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    final result = _userRepository().getUser(username);
    if(result.isLeft) {
      state = AsyncValue.error(result.left, StackTrace.current);
      return;
    }
    User storedUser = result.right;

    if(User.getHash(rawPassword, storedUser.salt) == storedUser.hash) {
      _userRepository().setCurrentUser(storedUser);
      state = AsyncValue.data(storedUser);
    }
    else {
      state = AsyncValue.error(MyError(errorMessage: "Username or Password incorrect!", location: "authenticateUser"), StackTrace.current);
    }
  }
}


