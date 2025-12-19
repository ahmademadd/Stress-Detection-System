import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stress_sense/core/constants/words.dart';
import 'package:stress_sense/core/theme/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/button_widget.dart';

class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({
    super.key,
    this.email,
  });

  late String? email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController controllerEmail = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controllerEmail.text = widget.email ?? "";
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    super.dispose();
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: Text(
        Words.pleaseCheckYourEmail,
        style: AppTextStyles.m,
      ),
      showCloseIcon: true,
    ));
  }
  Future<void> resetPassword() async {
    try {
      final email = controllerEmail.text.trim();

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      showSnackBar();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found for this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'Failed to reset password';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60.0),
              const Text(
                Words.resetPassword,
                style: AppTextStyles.xxlBold,
              ),
              const SizedBox(height: 20.0),
              const Text(
                '🔐',
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
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: Words.resetPassword,
          callback: () async {
            if (formKey.currentState!.validate()) {
              await resetPassword();
            }
          },
        ),
      ],
    );
  }
}
