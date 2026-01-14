import 'package:flutter/material.dart';
import 'package:bamclauncher/theme/blue_archive_theme.dart';
import 'package:bamclauncher/views/home_view.dart';

void main() {
  runApp(const BAMCLauncherApp());
}

class BAMCLauncherApp extends StatelessWidget {
  const BAMCLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAMCLauncher',
      theme: BlueArchiveTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
