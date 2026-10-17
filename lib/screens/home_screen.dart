import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Временная заглушка стартового экрана — будет заменена экраном «Мой день».
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Text(
          'Добро пожаловать в ${AppConstants.appName}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
