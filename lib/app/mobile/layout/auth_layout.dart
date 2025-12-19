import 'package:flutter/material.dart';
import 'package:stress_sense/core/notifiers/notifiers.dart';
import '../pages/main/onboarding/welcome_page.dart';
import 'app_navigation_layout.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppData.isAuthConnected,
      builder: (context, isAuthConnected, child) {
        Widget widget;
        if (isAuthConnected) {
          widget = const AppNavigationLayout();
        } else {
          widget = const WelcomePage();
        }
        return widget;
      },
    );
  }
}
