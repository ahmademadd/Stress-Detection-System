import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stress_sense/app/mobile/widgets/button_widget.dart';
import 'package:stress_sense/core/theme/app_text_styles.dart';

import '../../../../core/constants/words.dart';
import '../../../../core/notifiers/notifiers.dart';
import 'app_loading_page.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> deleteAccount() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AppLoadingPage()),
    );
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showErrorSnackBar('No authenticated user found.');
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      // Clear app state
      AppData.isAuthConnected.value = false;
      AppData.navBarCurrentIndexNotifier.value = 0;

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      popPage();
      if (!mounted) return;

      switch (e.code) {
        case 'wrong-password':
          showErrorSnackBar('Incorrect password.');
          break;
        case 'user-mismatch':
          showErrorSnackBar('Email does not match the current user.');
          break;
        case 'requires-recent-login':
          showErrorSnackBar('Please log in again before deleting your account.');
          break;
        default:
          showErrorSnackBar(e.message ?? 'Account deletion failed.');
      }
    } catch (_) {
      popPage();
      if (!mounted) return;
      showErrorSnackBar('Unexpected error occurred.');
    }
  }


  void popPage() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 60.0),
              const Text(
                Words.deleteMyAccount,
                style: AppTextStyles.xxlBold,
              ),
              const SizedBox(height: 20.0),
              const Text(
                '❌',
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
                          labelText: Words.enterYourEmail,
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return Words.enterSomething;
                          }
                          if (value.trim().isEmpty) {
                            return Words.enterSomething;
                          }
                          if (controllerEmail.text.contains('@') == false) {
                            return Words.invalidEmailEntered;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controllerPassword,
                        decoration: const InputDecoration(
                          labelText: Words.currentPassword,
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return Words.enterSomething;
                          }
                          if (value.trim().isEmpty) {
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
            ],
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          label: Words.deletePermanently,
          isFilled: true,
          callback: () {
            if (formKey.currentState!.validate()) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(Words.finalNotice),
                    content: const Text(
                      Words
                          .areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible,
                      style: AppTextStyles.m,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          popPage();
                          deleteAccount();
                        },
                        child: const Text(Words.deletePermanently),
                      ),
                      TextButton(
                        onPressed: () {
                          popPage();
                        },
                        child: const Text(Words.cancel),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
