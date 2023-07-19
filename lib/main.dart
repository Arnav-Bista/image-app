import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/authentication/presentation/authentication.dart';
import 'package:images/features/image/image_screen.dart';
import 'package:images/features/image/infrastructure/model/favourites.dart';
import 'package:images/features/image/infrastructure/model/photo.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PhotoAdapter());
  Hive.registerAdapter(FavouritesAdapter());
  await Hive.openBox<User>("users");
  await Hive.openBox<Favourites>("userdata");

  FlutterNativeSplash.remove();
  runApp(ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4), 
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
      ),
      home: Authentication(),
      // home: ImageScreen()
    );
  }
}
