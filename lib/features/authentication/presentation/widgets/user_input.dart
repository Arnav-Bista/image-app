import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:images/core/widgets/my_error.dart';

import 'package:images/features/authentication/application/controller/user_controller.dart';
import 'package:images/features/authentication/infrastructure/models/user.dart';
import 'package:images/features/image/image_screen.dart';


class UserInput extends ConsumerStatefulWidget {
  const UserInput({super.key});

  @override
  ConsumerState<UserInput> createState() => _UserInputState();
}

class _UserInputState extends ConsumerState<UserInput> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();  

  final formKey = GlobalKey<FormState>();

  bool confirm = false;


  final String _signInText = "Don't have an account?";
  final String _signUpText = "Already have an account?";

  void _clear() {
    usernameController.clear();
    passwordController.clear();
    confirmController.clear();
  }


  void _action(WidgetRef ref, GlobalKey<FormState> formKey) {
    if(!formKey.currentState!.validate()) {
      return;
    }
    if(confirm) {
      ref.read(userController.notifier).storeUser(
        usernameController.text,
        passwordController.text
      );
    }
    else {
      ref.read(userController.notifier).authenticateUser(
        usernameController.text,
        passwordController.text
      );
    }
    if(confirm) {
      _clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(userController);

    ref.listen<AsyncValue<User?>>(userController, (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((error as MyError).errorMessage))
          );
        },
        data: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(confirm ? "Signed Up!" : "Logged In"))
          );
          final read = ref.read(userController);
          if(read.hasValue && read.value != null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ImageScreen()));
          }
          if(confirm) {
            _clear();
            setState(() {
              confirm = false;
            });
          }
        },
        ));


    @override
    void dispose() {
      usernameController.dispose();
      passwordController.dispose();
      confirmController.dispose();
      super.dispose();
    }

    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              enabled: !controller.isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter a username";
                }
                else if (value.length < 3) {
                  return "Too short!";
                }
                return null;
              },
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Username",
                hintText: "username"
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: !controller.isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter a password";
                }
                else if (confirm && value != confirmController.text) {
                  return "Passwords do not match!";
                }
                else if (value.length < 3) {
                  return "Too short!";
                }
                return null;
              },
              controller: passwordController,
              obscureText: true,
              onEditingComplete: confirm ? null : () => _action(ref, formKey),
              textInputAction: confirm ? TextInputAction.next : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
                hintText: "*********",
              ),

              ),
              const SizedBox(height: 20),
              AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: 
                  TextFormField(
                    enabled: !controller.isLoading,
                    validator: (value) {
                      if(!confirm) {
                        return null;
                      }
                      if (value == null || value.isEmpty) {
                        return "Enter the same password";
                      }
                      else if (confirm && value != passwordController.text) {
                        return "Passwords do not match!";
                      }
                      return null;
                    },
                    controller: confirmController,
                    obscureText: true,
                    onEditingComplete: () => _action(ref, formKey),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirm Password",
                      hintText: "*********",
                    ),
                    ),
                    ),
                    secondChild: const SizedBox(), 
                    crossFadeState: confirm ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
                    duration: const Duration(milliseconds: 100),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: OutlinedButton(
                        onPressed: controller.isLoading ? null : () {
                          _action(ref, formKey);
                        },
                        child: controller.isLoading 
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator()
                        )
                        : Text(
                          "Submit",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _clear();
                        setState(() => confirm = !confirm);
                      },
                      child: Text(confirm ? _signUpText : _signInText),
                    ),
                    ],
                    ),
                    ),
                    );
  }
}

