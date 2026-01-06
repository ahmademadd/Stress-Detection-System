import 'package:flutter/material.dart';
import 'package:stress_sense/app/mobile/pages/main/explore/explore_page.dart';
import 'package:stress_sense/app/mobile/pages/main/monitor/monitor_page.dart';
import '../../../core/notifiers/notifiers.dart';
import '../pages/main/profile/profile_page.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

class AppNavigationLayout extends StatelessWidget {
  const AppNavigationLayout({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = const [
      MonitorPage(),
      ExplorePage(),
      ProfilePage(),
    ];
    return ValueListenableBuilder(
      valueListenable: AppData.navBarCurrentIndexNotifier,
      builder: (context, currentIndex, child) {
        return Scaffold(
          body: SafeArea(
            child: pages.elementAt(currentIndex),
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            onPressed: (int index) {
              AppData.navBarCurrentIndexNotifier.value = index;
            },
            selectedIndex: currentIndex,
          ),
        );
      },
    );
  }
}
