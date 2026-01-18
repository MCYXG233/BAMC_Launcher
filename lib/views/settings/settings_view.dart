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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Windows 11 风格的设置页面布局
    // 移除Scaffold，直接返回设置内容，适应HomeView右侧内容区域
    return SingleChildScrollView(
      // 使用标准滚动行为，移除安卓特有的弹性滚动
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      // 添加底部内边距，避免内容被裁剪
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '设置',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontFamily: 'NotoSansSC',
              ),
            ),
          ),
          
          // 主题设置部分
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('外观', theme),
                const SizedBox(height: 8),
                
                // 深色模式设置项 - Windows 11风格
                _buildSettingCard(
                  title: '深色模式',
                  description: '切换应用的主题样式',
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
                    activeColor: theme.colorScheme.primary,
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return theme.colorScheme.primary;
                      }
                      return theme.colorScheme.onSurface.withOpacity(0.38);
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return theme.colorScheme.primary.withOpacity(0.5);
                      }
                      return theme.colorScheme.onSurface.withOpacity(0.12);
                    }),
                  ),
                  theme: theme,
                ),
              ],
            ),
          ),

          // 语言设置部分
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('语言', theme),
                const SizedBox(height: 8),
                
                // 语言选择设置项
                _buildSettingCard(
                  title: '应用语言',
                  description: '更改应用的显示语言',
                  value: _language == 'zh_CN' ? '简体中文' : 'English',
                  onPressed: () {
                    // 语言选择对话框
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('选择语言', style: TextStyle(color: theme.colorScheme.onSurface)),
                        backgroundColor: theme.colorScheme.surface,
                        surfaceTintColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogOption('简体中文', () {
                              setState(() {
                                _language = 'zh_CN';
                                final settingsService = serviceLocator.get<SettingsService>();
                                settingsService.language = 'zh_CN';
                              });
                              Navigator.pop(context);
                            }, theme),
                            _buildDialogOption('English', () {
                              setState(() {
                                _language = 'en_US';
                                final settingsService = serviceLocator.get<SettingsService>();
                                settingsService.language = 'en_US';
                              });
                              Navigator.pop(context);
                            }, theme),
                          ],
                        ),
                      ),
                    );
                  },
                  theme: theme,
                ),
              ],
            ),
          ),

          // Java 设置部分
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Java 设置', theme),
                const SizedBox(height: 8),
                
                // Java 路径设置项
                _buildSettingCard(
                  title: 'Java 路径',
                  description: '设置 Java 运行环境路径',
                  value: _javaPath.isEmpty ? '未设置' : _javaPath,
                  onPressed: () {
                    // Java路径选择逻辑
                  },
                  theme: theme,
                ),
                const SizedBox(height: 8),
                
                // 内存分配设置项
                _buildSettingCard(
                  title: '内存分配',
                  description: '设置游戏运行时的内存分配',
                  value: '${_memory}MB',
                  onPressed: () {
                    // 内存设置对话框
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('设置内存分配', style: TextStyle(color: theme.colorScheme.onSurface)),
                        backgroundColor: theme.colorScheme.surface,
                        surfaceTintColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int mem in [1024, 2048, 3072, 4096, 6144, 8192])
                              _buildDialogOption('${mem}MB', () {
                                setState(() {
                                  _memory = mem;
                                  final settingsService = serviceLocator.get<SettingsService>();
                                  settingsService.memory = mem;
                                });
                                Navigator.pop(context);
                              }, theme),
                          ],
                        ),
                      ),
                    );
                  },
                  theme: theme,
                ),
              ],
            ),
          ),

          // 下载设置部分
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('下载设置', theme),
                const SizedBox(height: 8),
                
                // 下载源设置项
                _buildSettingCard(
                  title: '下载源',
                  description: '选择资源下载的服务器',
                  value: _downloadSource == 'default' ? '默认源' : '备用源',
                  onPressed: () {
                    // 下载源选择对话框
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('选择下载源', style: TextStyle(color: theme.colorScheme.onSurface)),
                        backgroundColor: theme.colorScheme.surface,
                        surfaceTintColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogOption('默认源', () {
                              setState(() {
                                _downloadSource = 'default';
                                final settingsService = serviceLocator.get<SettingsService>();
                                settingsService.downloadSource = 'default';
                              });
                              Navigator.pop(context);
                            }, theme),
                            _buildDialogOption('备用源', () {
                              setState(() {
                                _downloadSource = 'mirror';
                                final settingsService = serviceLocator.get<SettingsService>();
                                settingsService.downloadSource = 'mirror';
                              });
                              Navigator.pop(context);
                            }, theme),
                          ],
                        ),
                      ),
                    );
                  },
                  theme: theme,
                ),
              ],
            ),
          ),

          // 关于部分
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('关于', theme),
                const SizedBox(height: 8),
                
                // 关于信息卡片
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAboutRow('版本', '1.0.0', theme),
                        _buildAboutRow('开发者', 'BAMC Team', theme),
                        _buildAboutRow('GitHub', 'https://github.com/BAMCLauncher', theme, isLink: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建Windows 11风格的设置卡片
  Widget _buildSettingCard({
    required String title,
    required String description,
    String? value,
    Widget? trailing,
    VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
          focusColor: theme.colorScheme.onSurface.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, 
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(description, 
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          letterSpacing: 0.05,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(height: 4),
                        Text(value, 
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (trailing != null) trailing else 
                Row(
                  children: [
                    if (onPressed != null) ...[
                      Text('更改', 
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建Windows 11风格的对话框选项
  Widget _buildDialogOption(String title, VoidCallback onPressed, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
        focusColor: theme.colorScheme.onSurface.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, 
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  letterSpacing: 0.05,
                ),
              ),
              Icon(
                Icons.check,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建关于行
  Widget _buildAboutRow(String label, String value, ThemeData theme, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, 
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, 
            style: TextStyle(
              color: isLink ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontSize: 15,
              decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  // 构建Windows 11风格的节标题
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
