import 'package:flutter/material.dart';
import '../../../../../core/constants/words.dart';
import '../../../scaffolds/app_bar_scaffold.dart';
import 'widgets/explore_recommended_widget.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBarScaffold(
      title: 'Explore Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeRecommendedWidget(),
        ],
      ),
    );
  }
}
