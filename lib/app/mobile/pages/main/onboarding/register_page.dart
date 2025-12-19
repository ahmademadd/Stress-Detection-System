import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/pages/main/onboarding/onboarding_pages.dart';
import 'package:stress_sense/app/mobile/pages/main/onboarding/welcome_page.dart';
import 'package:stress_sense/core/theme/app_text_styles.dart';
import '../../../../../core/constants/words.dart';
import '../../../../../core/notifiers/notifiers.dart';
import '../../../../../core/routes/page_route_return.dart';
import '../../../scaffolds/app_bottom_bar_buttons.dart';
import '../../../widgets/button_widget.dart';
import 'widgets/bottom_stepper_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  Future<void> register() async {
    try {
      final email = controllerEmail.text.trim();
      final password = controllerPassword.text.trim();

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User created successfully
      AppData.isAuthConnected.value = true;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email is already registered';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
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
        title: const Text("StressSense"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 60.0),
              const Text(
                Words.register,
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
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Email is required"),
                          EmailValidator(errorText: "Enter a valid email"),
                        ]).call,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        controller: controllerPassword,
                        decoration: const InputDecoration(
                          labelText: Words.password,
                        ),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Password required'),
                          MinLengthValidator(8,
                              errorText: 'At least 8 characters'),
                          PatternValidator(r'(?=.*?[A-Z])',
                              errorText:
                                  'Must have at least one uppercase letter'),
                          PatternValidator(r'(?=.*?[0-9])',
                              errorText: 'Must have at least one number'),
                          PatternValidator(r'(?=.*?[!@#\$&*~])',
                              errorText: 'Must have a special char'),
                        ]).call,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                        ),
                        validator: (val) =>
                            MatchValidator(errorText: 'passwords do not match')
                                .validateMatch(val!, controllerPassword.text.trim()),
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
          isFilled: true,
          label: Words.register,
          callback: () {
            if (formKey.currentState!.validate()) {
              register();
            }
          },
        ),
      ],
    );
  }
}
