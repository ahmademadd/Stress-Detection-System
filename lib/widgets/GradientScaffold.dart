import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;

  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF869EB5),
      //   centerTitle: true,
      //   title: Text(
      //     'StressSense',
      //     style: TextStyle(
      //       fontFamily: 'Sirivennela-Regular',
      //       fontSize: 44,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFeff6ff), // blue-50
              Color(0xFFe0e7ff), // indigo-100
            ],
          ),
        ),
        child: child,
      ),

    );
  }
}
