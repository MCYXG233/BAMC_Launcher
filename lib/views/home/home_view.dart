import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bamclauncher/components/anime_button.dart';
import 'package:bamclauncher/components/windows_button.dart';
import 'package:bamclauncher/components/windows_card.dart';
import 'package:bamclauncher/theme/blue_archive_theme.dart';
import 'package:bamclauncher/views/settings/settings_view.dart';
import 'package:bamclauncher/views/download/download_view.dart';

// 主应用视图，使用单Scaffold多页面切换
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

// 页面类型枚举
enum AppPage {
  home,
  instances,
  packs,
  p2p,
  downloads,
  settings,
}

class _HomeViewState extends State<HomeView> {
  // 当前选中的页面
  AppPage _selectedPage = AppPage.home;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      // 单一Scaffold，避免嵌套
      body: Stack(
        children: [
          // 背景图 - 暂时使用主题渐变背景，后续可替换为真实图片
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode 
                    ? BlueArchiveTheme.gradientBackgroundDark 
                    : BlueArchiveTheme.gradientBackgroundLight,
              ),
            ),
          ),
          
          // 半透明覆盖层，增强文字可读性
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          
          // 主内容区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧导航栏 - 液态玻璃效果
                _buildGlassContainer(
                  width: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        'BAMCLauncher',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // 导航项
                      _buildNavItem(
                        context, 
                        Icons.home, 
                        '主页',
                        isActive: _selectedPage == AppPage.home,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.home;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context, 
                        Icons.gamepad, 
                        '我的实例',
                        isActive: _selectedPage == AppPage.instances,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.instances;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context, 
                        Icons.download, 
                        '整合包',
                        isActive: _selectedPage == AppPage.packs,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.packs;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context, 
                        Icons.people, 
                        'P2P 联机',
                        isActive: _selectedPage == AppPage.p2p,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.p2p;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context, 
                        Icons.cloud_download, 
                        '下载中心',
                        isActive: _selectedPage == AppPage.downloads,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.downloads;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        context, 
                        Icons.settings, 
                        '设置',
                        isActive: _selectedPage == AppPage.settings,
                        onTap: () {
                          setState(() {
                            _selectedPage = AppPage.settings;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      
                      // 快速操作
                      Text(
                        '快速操作',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 快速操作按钮
                      Column(
                        children: [
                          AnimeButton(
                            text: '新建实例',
                            onPressed: () {
                              print('新建实例按钮被点击');
                              // 切换到实例页面
                              setState(() {
                                _selectedPage = AppPage.instances;
                              });
                              // TODO: 弹出新建实例对话框
                            },
                            leadingIcon: const Icon(Icons.add, size: 24),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          const SizedBox(height: 12),
                          AnimeButton(
                            text: '导入整合包',
                            onPressed: () {
                              print('导入整合包按钮被点击');
                              // 切换到整合包页面
                              setState(() {
                                _selectedPage = AppPage.packs;
                              });
                              // TODO: 弹出导入整合包对话框
                            },
                            leadingIcon: const Icon(Icons.file_download, size: 24),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            isPrimary: false,
                          ),
                          const SizedBox(height: 12),
                          AnimeButton(
                            text: '下载游戏',
                            onPressed: () {
                              print('下载游戏按钮被点击');
                              // 切换到下载中心
                              setState(() {
                                _selectedPage = AppPage.downloads;
                              });
                              // TODO: 跳转到游戏下载页面
                            },
                            leadingIcon: const Icon(Icons.cloud_download, size: 24),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                  theme: theme,
                ),
                
                const SizedBox(width: 16),
                
                // 右侧内容区域 - 液态玻璃效果
                Expanded(
                  child: _buildGlassContainer(
                    child: _buildPageContent(),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 根据选中的页面构建内容
  Widget _buildPageContent() {
    switch (_selectedPage) {
      case AppPage.home:
        return _buildHomePage();
      case AppPage.instances:
        // 移除Scaffold的实例列表组件
        return const _InstancesContent();
      case AppPage.packs:
        // 整合包页面内容
        return const _PacksContent();
      case AppPage.p2p:
        // P2P页面内容
        return const _P2PContent();
      case AppPage.downloads:
        // 下载中心页面内容
        return const DownloadView();
      case AppPage.settings:
        // 设置页面内容
        return const SettingsView();
    }
  }
  
  // 主页内容
  Widget _buildHomePage() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 功能卡片区域
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  theme: theme,
                  title: '我的实例',
                  subtitle: '管理你的 Minecraft 实例',
                  icon: Icons.gamepad,
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    setState(() {
                      _selectedPage = AppPage.instances;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  theme: theme,
                  title: '整合包',
                  subtitle: '导入和管理整合包',
                  icon: Icons.download,
                  color: const Color(0xFFEC4899),
                  onTap: () {
                    setState(() {
                      _selectedPage = AppPage.packs;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  theme: theme,
                  title: 'P2P 联机',
                  subtitle: '创建或加入 P2P 房间',
                  icon: Icons.people,
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    setState(() {
                      _selectedPage = AppPage.p2p;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  theme: theme,
                  title: '下载中心',
                  subtitle: '下载游戏和资源',
                  icon: Icons.cloud_download,
                  color: const Color(0xFFEAB308),
                  onTap: () {
                    setState(() {
                      _selectedPage = AppPage.downloads;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 我的实例
          Text(
            '我的实例',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontFamily: 'NotoSansSC',
            ),
          ),
          const SizedBox(height: 20),
          
          // 实例列表预览
          Column(
            children: [
              _buildInstanceCard(
                theme: theme,
                title: 'Example Instance',
                subtitle: 'Minecraft 1.19.4 - Fabric 0.15.3',
                icon: Icon(
                  Icons.gamepad,
                  size: 56,
                  color: const Color(0xFF6366F1),
                ),
                onTap: () {
                  setState(() {
                    _selectedPage = AppPage.instances;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildInstanceCard(
                theme: theme,
                title: 'Creative World',
                subtitle: 'Minecraft 1.20.1 - Forge 47.2.0',
                icon: Icon(
                  Icons.brush,
                  size: 56,
                  color: const Color(0xFFEC4899),
                ),
                onTap: () {
                  setState(() {
                    _selectedPage = AppPage.instances;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // 最近更新
          Text(
            '最近更新',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontFamily: 'NotoSansSC',
            ),
          ),
          const SizedBox(height: 20),
          
          // 更新卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BAMCLauncher 1.0.0',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: 'NotoSansSC',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '• 实现了基于 Blue Archive 风格的 UI 设计\n• 采用了左侧导航栏+右侧内容区域的经典布局\n• 支持多种整合包格式的导入\n• 支持实例的自动识别和管理',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'NotoSansSC',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
  
  // 构建导航项
  Widget _buildNavItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    {bool isActive = false, VoidCallback? onTap}
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontFamily: 'NotoSansSC',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建功能卡片
  Widget _buildFeatureCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: 'NotoSansSC',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'NotoSansSC',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建实例卡片
  Widget _buildInstanceCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 图标
            icon,
            const SizedBox(width: 20),
            
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                ],
              ),
            ),
            
            // 操作按钮
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                  onPressed: () {
                    print('启动实例: $title');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    print('进入实例设置: $title');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    print('更多操作: $title');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建液态玻璃容器
  Widget _buildGlassContainer({
    required Widget child,
    required ThemeData theme,
    double? width,
    double? height,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDarkMode 
                ? theme.colorScheme.surface.withOpacity(0.6) 
                : theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode 
                  ? theme.colorScheme.outlineVariant.withOpacity(0.4) 
                  : theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.3) 
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

// 实例列表内容组件 - 移除Scaffold
class _InstancesContent extends StatefulWidget {
  const _InstancesContent();

  @override
  State<_InstancesContent> createState() => __InstancesContentState();
}

class __InstancesContentState extends State<_InstancesContent> {
  // 模拟实例数据
  final List<Map<String, dynamic>> _instances = [
    {
      'id': '1',
      'name': 'Example Instance',
      'version': '1.19.4',
      'loader': 'Fabric 0.15.3',
    },
    {
      'id': '2',
      'name': 'Creative World',
      'version': '1.20.1',
      'loader': 'Forge 47.2.0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            '我的实例',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontFamily: 'NotoSansSC',
            ),
          ),
        ),
        
        // 操作按钮区
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              WindowsButton(
                text: '新建实例',
                onPressed: () {
                  print('新建实例');
                },
                leadingIcon: const Icon(Icons.add, size: 18),
                height: 36,
              ),
              const SizedBox(width: 8),
              WindowsButton(
                text: '导入整合包',
                onPressed: () {
                  print('导入整合包');
                },
                leadingIcon: const Icon(Icons.upload_file, size: 18),
                isPrimary: false,
                height: 36,
              ),
              const SizedBox(width: 8),
              WindowsButton(
                text: '扫描实例',
                onPressed: () {
                  print('扫描实例');
                },
                leadingIcon: const Icon(Icons.search, size: 18),
                isPrimary: false,
                height: 36,
              ),
            ],
          ),
        ),
        
        // 实例列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: _instances.length,
            itemBuilder: (context, index) {
              final instance = _instances[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WindowsCard(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.gamepad,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instance['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Minecraft ${instance['version']} - ${instance['loader']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WindowsIconButton(
                              icon: Icon(Icons.play_arrow, size: 20),
                              onPressed: () {
                                print('启动实例: ${instance['name']}');
                              },
                              tooltip: '启动实例',
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            WindowsIconButton(
                              icon: Icon(Icons.settings, size: 20),
                              onPressed: () {
                                print('实例设置: ${instance['name']}');
                              },
                              tooltip: '实例设置',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 整合包页面内容
class _PacksContent extends StatelessWidget {
  const _PacksContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '整合包管理',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '导入和管理你的 Minecraft 整合包',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// P2P页面内容
class _P2PContent extends StatelessWidget {
  const _P2PContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'P2P 联机',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建或加入 P2P 房间',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


