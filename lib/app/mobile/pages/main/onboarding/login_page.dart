import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/pages/main/onboarding/welcome_page.dart';
import 'package:stress_sense/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stress_sense/core/notifiers/notifiers.dart';
import 'package:stress_sense/core/theme/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/constants/words.dart';
import '../../../../../core/routes/page_route_return.dart';
import '../../../widgets/button_widget.dart';
import '../../others/app_loading_page.dart';
import '../../others/reset_password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AppLoadingPage()),
    );
    try {
      final email = controllerEmail.text.trim();
      final password = controllerPassword.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppData.isAuthConnected.value = true;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      popPage();

      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (_) {
      popPage();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AppLoadingPage()),
    );
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        popPage();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      AppData.isAuthConnected.value = true;
      Navigator.of(context).popUntil((route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      popPage();

      String errorMessage;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
          'An account already exists with a different sign-in method';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid authentication credentials';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = e.message ?? 'Google sign-in failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

    } catch (_) {
      popPage();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }


  void popPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => popPage(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Text(
                Words.signIn,
                style: AppTextStyles.xxlBold,
              ),
              const SizedBox(height: 20.0),
              const Text(
                '🔑',
                style: AppTextStyles.icons,
              ),
              const SizedBox(height: 50),
              Form(
                key: formKey,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controllerEmail,
                        decoration: const InputDecoration(
                          labelText: Words.email,
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return Words.enterSomething;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controllerPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: Words.password,
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return Words.enterSomething;
                          }
                          return null;
                        },
                        style: AppTextStyles.m,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ResetPasswordPage(
                                      email: controllerEmail.text);
                                },
                              ),
                            );
                          },
                          child: const Text(Words.resetPassword),
                        ),
                      ),
                      Text(
                        "Or",
                        style: AppTextStyles.m.copyWith(color: Colors.white54),
                      ),
                      SizedBox(height: 20),
                      SignInButton(
                        width: 250,
                        shape: Border.all(strokeAlign: 3, width:3 , color: Colors.white),
                        padding: EdgeInsets.all(3),
                        Buttons.Google,
                        text: "Sign in with Google",
                        onPressed: signInWithGoogle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: Words.signIn,
          callback: () {
            if (formKey.currentState!.validate()) {
              signIn();
            }
          },
        ),
      ],
    );
  }
}
