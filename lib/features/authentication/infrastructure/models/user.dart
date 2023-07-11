import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(
      username: reader.readString(),
      hash: reader.readString(),
      salt: reader.readString(),
    );
  }

  @override
    void write(BinaryWriter writer, User obj) {
      writer.writeString(obj.username);
      writer.writeString(obj.hash);
      writer.writeString(obj.salt);
    }
}



class User {

  final String username;
  final String hash;
  final String salt;

  User({required this.username, required this.hash, required this.salt});

  static User createUser(String username, String rawPassword) {
    String salt = DateTime.now().toString();
    String hash = getHash(rawPassword, salt);
    return User(username: username, hash: hash, salt: salt);
  }

  static String getHash(String rawPassword, String salt) {
    const String pepper = "()***    )*@A<:\"?><{}";
    return sha256.convert(utf8.encode(pepper + rawPassword + salt + pepper)).toString();
  }


}
