import 'package:flutter/material.dart';
import 'package:bamclauncher/services/service_locator.dart';
import 'package:bamclauncher/services/settings_service.dart';
import 'package:bamclauncher/main.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isDarkMode = false;
  String _language = 'zh_CN';
  String _javaPath = '';
  int _memory = 2048;
  String _downloadSource = 'default';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsService = serviceLocator.get<SettingsService>();
    setState(() {
      _isDarkMode = settingsService.isDarkMode;
      _language = settingsService.language;
      _javaPath = settingsService.javaPath;
      _memory = settingsService.memory;
      _downloadSource = settingsService.downloadSource;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设置
              _buildSectionTitle('主题设置'),
              Card(
                child: ListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('切换应用的主题样式'),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                            final settingsService = serviceLocator.get<SettingsService>();
                            settingsService.darkMode = value;
                            // 使用 ThemeToggleScope 来切换主题
                            final themeScope = ThemeToggleScope.of(context);
                            if (themeScope != null) {
                              themeScope.toggleTheme();
                            }
                          });
                        },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 语言设置
              _buildSectionTitle('语言设置'),
              Card(
                child: ListTile(
                  title: const Text('语言'),
                  subtitle: Text(_language == 'zh_CN' ? '简体中文' : 'English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 语言选择对话框
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('选择语言'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('简体中文'),
                              onTap: () {
                                setState(() {
                                  _language = 'zh_CN';
                                  final settingsService = serviceLocator.get<SettingsService>();
                                  settingsService.language = 'zh_CN';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('English'),
                              onTap: () {
                                setState(() {
                                  _language = 'en_US';
                                  final settingsService = serviceLocator.get<SettingsService>();
                                  settingsService.language = 'en_US';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Java 设置
              _buildSectionTitle('Java 设置'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Java 路径'),
                      subtitle: Text(_javaPath.isEmpty ? '未设置' : _javaPath),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Java路径选择逻辑
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('内存分配'),
                      subtitle: Text('${_memory}MB'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // 内存设置对话框
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('设置内存分配'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int mem in [1024, 2048, 3072, 4096, 6144, 8192])
                                  ListTile(
                                    title: Text('${mem}MB'),
                                    onTap: () {
                                      setState(() {
                                        _memory = mem;
                                        final settingsService = serviceLocator.get<SettingsService>();
                                        settingsService.memory = mem;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 下载设置
              _buildSectionTitle('下载设置'),
              Card(
                child: ListTile(
                  title: const Text('下载源'),
                  subtitle: Text(_downloadSource == 'default' ? '默认源' : '备用源'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 下载源选择对话框
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('选择下载源'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('默认源'),
                              onTap: () {
                                setState(() {
                                  _downloadSource = 'default';
                                  final settingsService = serviceLocator.get<SettingsService>();
                                  settingsService.downloadSource = 'default';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('备用源'),
                              onTap: () {
                                setState(() {
                                  _downloadSource = 'mirror';
                                  final settingsService = serviceLocator.get<SettingsService>();
                                  settingsService.downloadSource = 'mirror';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 关于
              _buildSectionTitle('关于'),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      title: Text('版本'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      title: Text('开发者'),
                      subtitle: Text('BAMC Team'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('GitHub'),
                      subtitle: const Text('https://github.com/BAMCLauncher'),
                      onTap: () {
                        // 打开GitHub链接
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
