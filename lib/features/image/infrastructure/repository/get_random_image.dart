import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:images/core/widgets/my_error.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';
import 'package:html/parser.dart';

final photoRepository = Provider<IGetRandomImage>((ref) =>
  GetRandomImage()
  );

abstract class IGetRandomImage {
  Future<Either<MyError, Photo>> getImage();
}


class GetRandomImage implements IGetRandomImage {

  // Prevent internal caching
  static Uri baseUrl = Uri.parse("https://picsum.photos/1000");

  final http.Client client = http.Client();
  
  Future<Either<Map<String, String>,MyError>> _getHeaders(Uri uri) async {
    try{
    final headers = (await client.get(uri, headers: {"method": "HEAD"})).headers;
    return Left(headers);
    }
    catch(e) {
      return Right(MyError(errorMessage: "Header fetch error $e", location: "getHeaders"));
    }

  }

  @override
  Future<Either<MyError, Photo>> getImage() async {
    final headerResponse = await _getHeaders(baseUrl);
    if(headerResponse.isRight) {
      return Left(headerResponse.right);
    }
    final Map<String,String> headers = headerResponse.left;
    final response = await client.get(Uri.parse("https://picsum.photos/id/${headers["picsum-id"]}/info"));
    if(response.statusCode != 200) {
      return Left(MyError(errorMessage: "Fetch Error ${response.statusCode}", location: "getImage"));
    }
    final parsedResponse = jsonDecode(response.body);
    return Right(Photo.fromJson(parsedResponse));
  }
}
