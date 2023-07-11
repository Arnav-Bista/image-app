import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/features/authentication/application/controller/user_controller.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/authentication/presentation/widgets/user_input.dart';
import 'package:images/features/image/image_screen.dart';

class Authentication extends ConsumerWidget{
  const Authentication({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images", textAlign: TextAlign.center)
      ),
      body: UserInput(),
    );
  }
}

