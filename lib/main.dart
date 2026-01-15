import 'package:flutter/material.dart';
import 'package:bamclauncher/theme/blue_archive_theme.dart';
import 'package:bamclauncher/views/home/home_view.dart';
import 'package:bamclauncher/services/service_locator.dart';
import 'package:bamclauncher/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化服务定位器
  await serviceLocator.initialize();
  runApp(const BAMCLauncherApp());
}

class BAMCLauncherApp extends StatefulWidget {
  const BAMCLauncherApp({super.key});

  @override
  State<BAMCLauncherApp> createState() => _BAMCLauncherAppState();
}

class _BAMCLauncherAppState extends State<BAMCLauncherApp> {
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  // 加载设置
  Future<void> _loadSettings() async {
    final settingsService = serviceLocator.get<SettingsService>();
    
    setState(() {
      _isDarkMode = settingsService.isDarkMode;
    });
  }
  
  // 切换主题
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      final settingsService = serviceLocator.get<SettingsService>();
      settingsService.darkMode = _isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAMCLauncher',
      theme: BlueArchiveTheme.lightTheme,
      darkTheme: BlueArchiveTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
      // 提供主题切换方法给子组件
      builder: (context, child) {
        return ThemeToggleScope(
          isDarkMode: _isDarkMode,
          toggleTheme: _toggleTheme,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

// 主题切换范围，用于在组件树中传递主题切换功能
class ThemeToggleScope extends InheritedWidget {
  final bool isDarkMode;
  final void Function() toggleTheme;
  
  const ThemeToggleScope({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });
  
  static ThemeToggleScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeToggleScope>();
  }
  
  @override
  bool updateShouldNotify(ThemeToggleScope oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
