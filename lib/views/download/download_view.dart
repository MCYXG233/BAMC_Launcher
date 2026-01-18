import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bamclauncher/components/windows_button.dart';
import 'package:bamclauncher/components/windows_card.dart';
import 'package:bamclauncher/components/anime_button.dart';

// 下载任务状态枚举
enum DownloadStatus {
  queued,      // 排队中
  downloading, // 下载中
  paused,      // 已暂停
  completed,   // 已完成
  failed,      // 下载失败
}

// 版本类型枚举
enum VersionType {
  release,    // 正式版
  snapshot,   // 快照版
  beta,       // 测试版
  alpha,      // 阿尔法版
  special,    // 特殊版本
}

// 下载任务类
class DownloadTask {
  final String id;
  final String name;
  final String type;
  final String url;
  final String targetPath;
  double progress;
  int speed;
  int eta;
  DownloadStatus status;
  
  DownloadTask({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.targetPath,
    this.progress = 0.0,
    this.speed = 0,
    this.eta = 0,
    this.status = DownloadStatus.queued,
  });
}

// 下载类型枚举
enum DownloadContentType {
  minecraft,
  forge,
  neoforge,
  fabric,
  quilt,
  optifine,
  fabricApi,
  optifabric,
  liteloader,
}

// 游戏版本类
class GameVersion {
  final String version;
  final VersionType type;
  final String tag;
  final bool isLTS;
  final int downloadCount;
  final String releaseTime;
  final String jsonUrl;
  final String jarUrl;
  
  GameVersion({
    required this.version,
    required this.type,
    required this.tag,
    this.isLTS = false,
    this.downloadCount = 0,
    required this.releaseTime,
    required this.jsonUrl,
    required this.jarUrl,
  });
}

// 下载中心页面
class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  // 下载任务列表
  List<DownloadTask> _downloadTasks = [];
  
  // 游戏版本列表 - 模拟从服务加载的数据
  List<GameVersion> _gameVersions = [
    GameVersion(
      version: '1.20.4',
      type: VersionType.release,
      tag: '最新版本',
      isLTS: false,
      downloadCount: 125432,
      releaseTime: '2023-12-19',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launcher.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.20.1',
      type: VersionType.release,
      tag: '稳定版本',
      isLTS: false,
      downloadCount: 234567,
      releaseTime: '2023-06-12',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launcher.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.19.4',
      type: VersionType.release,
      tag: '长期支持',
      isLTS: true,
      downloadCount: 345678,
      releaseTime: '2023-03-14',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launcher.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.18.2',
      type: VersionType.release,
      tag: '经典版本',
      isLTS: true,
      downloadCount: 456789,
      releaseTime: '2022-02-28',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launchermeta.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.17.1',
      type: VersionType.release,
      tag: '经典版本',
      isLTS: false,
      downloadCount: 567890,
      releaseTime: '2021-07-06',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launchermeta.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.16.5',
      type: VersionType.release,
      tag: '经典版本',
      isLTS: true,
      downloadCount: 678901,
      releaseTime: '2021-01-15',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launchermeta.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.15.2',
      type: VersionType.release,
      tag: '经典版本',
      isLTS: false,
      downloadCount: 789012,
      releaseTime: '2020-01-17',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launchermeta.mojang.com/v1/objects/...',
    ),
    GameVersion(
      version: '1.14.4',
      type: VersionType.release,
      tag: '经典版本',
      isLTS: false,
      downloadCount: 890123,
      releaseTime: '2019-07-19',
      jsonUrl: 'https://launchermeta.mojang.com/v1/packages/...',
      jarUrl: 'https://launchermeta.mojang.com/v1/objects/...',
    ),
  ];
  
  // 下载过滤选项
  DownloadStatus? _filter;
  
  // 下载源选择
  String _selectedDownloadSource = 'bmclapi'; // mojang, bmclapi, mcversions
  
  // 定时器用于模拟下载进度
  late Timer _downloadTimer;
  
  // 模拟下载任务
  List<DownloadTask> _simulatedTasks = [
    DownloadTask(
      id: '1',
      name: 'Minecraft 1.19.4',
      type: 'game',
      url: 'https://bmclapi2.bangbang93.com/version/1.19.4/client',
      targetPath: 'versions/1.19.4/1.19.4.jar',
      progress: 65.0,
      speed: 2500000,
      eta: 30,
      status: DownloadStatus.downloading,
    ),
    DownloadTask(
      id: '2',
      name: 'Fabric Loader 0.15.3',
      type: 'loader',
      url: 'https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.15.3/fabric-loader-0.15.3.jar',
      targetPath: 'libraries/net/fabricmc/fabric-loader/0.15.3/fabric-loader-0.15.3.jar',
      progress: 100.0,
      speed: 0,
      eta: 0,
      status: DownloadStatus.completed,
    ),
    DownloadTask(
      id: '3',
      name: 'OptiFine HD U I9',
      type: 'mod',
      url: 'https://optifine.net/downloadx?f=OptiFine_1.19.4_HD_U_I9.jar',
      targetPath: 'mods/OptiFine_1.19.4_HD_U_I9.jar',
      progress: 23.0,
      speed: 1800000,
      eta: 80,
      status: DownloadStatus.downloading,
    ),
  ];

  // 折叠面板状态
  Map<DownloadContentType, bool> _expandedPanels = {
    DownloadContentType.minecraft: true,
    DownloadContentType.forge: false,
    DownloadContentType.neoforge: false,
    DownloadContentType.fabric: false,
    DownloadContentType.quilt: false,
    DownloadContentType.optifine: false,
    DownloadContentType.fabricApi: false,
    DownloadContentType.optifabric: false,
    DownloadContentType.liteloader: false,
  };

  // 切换折叠面板状态
  void _togglePanel(DownloadContentType type) {
    setState(() {
      _expandedPanels[type] = !_expandedPanels[type]!;
    });
  }

  @override
  void initState() {
    super.initState();
    _downloadTasks = _simulatedTasks;
    // 启动模拟下载进度更新
    _downloadTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          for (var task in _downloadTasks) {
            if (task.status == DownloadStatus.downloading) {
              // 模拟进度更新
              task.progress += 0.5;
              if (task.progress >= 100) {
                task.progress = 100;
                task.status = DownloadStatus.completed;
                task.speed = 0;
                task.eta = 0;
              } else {
                // 模拟速度变化
                task.speed = (2000000 + (task.speed % 1000000)).toInt();
                // 模拟ETA计算
                task.eta = ((100 - task.progress) / 0.5).toInt();
              }
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // 取消定时器，避免内存泄漏和setState()调用错误
    _downloadTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题和下载源选择
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '下载中心',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontFamily: 'NotoSansSC',
              ),
            ),
            // 下载源选择下拉菜单
            Row(
              children: [
                Text(
                  '下载源：', 
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedDownloadSource,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDownloadSource = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'mojang',
                      child: Text('Mojang 官方'),
                    ),
                    DropdownMenuItem(
                      value: 'bmclapi',
                      child: Text('BMCLAPI'),
                    ),
                    DropdownMenuItem(
                      value: 'mcversions',
                      child: Text('MCVersions'),
                    ),
                  ],
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  dropdownColor: theme.colorScheme.surface,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // 主要内容区域
        Expanded(
          child: Row(
            children: [
              // 左侧边栏 - 下载分类
              SizedBox(
                width: 200,
                child: WindowsCard(
                  margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '下载分类',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryItem('全部', null, theme),
                      const SizedBox(height: 8),
                      _buildCategoryItem('下载中', DownloadStatus.downloading, theme),
                      const SizedBox(height: 8),
                      _buildCategoryItem('已暂停', DownloadStatus.paused, theme),
                      const SizedBox(height: 8),
                      _buildCategoryItem('已完成', DownloadStatus.completed, theme),
                      const SizedBox(height: 8),
                      _buildCategoryItem('下载失败', DownloadStatus.failed, theme),
                      const SizedBox(height: 24),
                      Text(
                        '下载管理',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: WindowsButton(
                          text: '全部暂停',
                          onPressed: () {
                            _pauseAllDownloads();
                          },
                          leadingIcon: const Icon(Icons.pause, size: 18),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: WindowsButton(
                          text: '全部删除',
                          onPressed: () {
                            _deleteAllDownloads();
                          },
                          leadingIcon: const Icon(Icons.delete, size: 18),
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 右侧内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 下载任务列表
                      Text(
                        '下载任务',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDownloadTasks(theme),
                      const SizedBox(height: 32),
                      
                      // 下载内容区域 - 采用PCL风格的卡片式折叠设计
                      Text(
                        '下载内容',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Minecraft 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.minecraft,
                        title: 'Minecraft',
                        icon: Icons.gamepad,
                        color: const Color(0xFF10B981),
                        content: _buildMinecraftVersions(theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // Forge 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.forge,
                        title: 'Forge',
                        icon: Icons.fireplace,
                        color: const Color(0xFFEF4444),
                        content: _buildLoaderVersions('Forge', theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // NeoForge 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.neoforge,
                        title: 'NeoForge',
                        icon: Icons.fireplace,
                        color: const Color(0xFFF59E0B),
                        content: _buildLoaderVersions('NeoForge', theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // Fabric 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.fabric,
                        title: 'Fabric',
                        icon: Icons.code,
                        color: const Color(0xFF0078D4),
                        content: _buildLoaderVersions('Fabric', theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // Quilt 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.quilt,
                        title: 'Quilt',
                        icon: Icons.code,
                        color: const Color(0xFF8B5CF6),
                        content: _buildLoaderVersions('Quilt', theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // OptiFine 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.optifine,
                        title: 'OptiFine',
                        icon: Icons.photo_filter,
                        color: const Color(0xFF6366F1),
                        content: _buildOptiFineVersions(theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // Fabric API 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.fabricApi,
                        title: 'Fabric API',
                        icon: Icons.api,
                        color: const Color(0xFF06B6D4),
                        content: _buildFabricApiVersions(theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // OptiFabric 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.optifabric,
                        title: 'OptiFabric',
                        icon: Icons.merge,
                        color: const Color(0xFFEC4899),
                        content: _buildOptiFabricVersions(theme),
                      ),
                      const SizedBox(height: 12),
                      
                      // LiteLoader 版本下载卡片
                      _buildCollapsibleCard(
                        theme: theme,
                        type: DownloadContentType.liteloader,
                        title: 'LiteLoader',
                        icon: Icons.lightbulb,
                        color: const Color(0xFFFBBF24),
                        content: _buildLiteLoaderVersions(theme),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建现代化折叠卡片
  Widget _buildCollapsibleCard({
    required ThemeData theme,
    required DownloadContentType type,
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    final isExpanded = _expandedPanels[type]!;
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 卡片头部 - 可点击折叠
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _togglePanel(type),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontFamily: 'NotoSansSC',
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 折叠内容
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  // 构建现代化 Minecraft 版本列表
  Widget _buildMinecraftVersions(ThemeData theme) {
    return Column(
      children: [
        // 最新版本推荐
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            '最新版本',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontFamily: 'NotoSansSC',
            ),
          ),
        ),
        // 版本列表
        for (var version in _gameVersions) 
          _buildGameVersionItem(version, theme),
      ],
    );
  }

  // 构建加载器版本列表
  Widget _buildLoaderVersions(String loaderName, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          '版本列表加载中...',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 构建 OptiFine 版本列表
  Widget _buildOptiFineVersions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'OptiFine 版本列表加载中...',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 构建 Fabric API 版本列表
  Widget _buildFabricApiVersions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Fabric API 版本列表加载中...',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 构建 OptiFabric 版本列表
  Widget _buildOptiFabricVersions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'OptiFabric 版本列表加载中...',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 构建 LiteLoader 版本列表
  Widget _buildLiteLoaderVersions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'LiteLoader 版本列表加载中...',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  // 构建分类项
  Widget _buildCategoryItem(String title, DownloadStatus? status, ThemeData theme) {
    final isActive = _filter == status;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = status;
        });
      },
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // 构建下载任务列表
  Widget _buildDownloadTasks(ThemeData theme) {
    // 根据过滤条件筛选下载任务
    List<DownloadTask> filteredTasks = _downloadTasks;
    if (_filter != null) {
      filteredTasks = _downloadTasks.where((task) => task.status == _filter).toList();
    }
    
    if (filteredTasks.isEmpty) {
      // 空状态
      return WindowsCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '暂无下载任务',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                WindowsButton(
                  text: '浏览游戏版本',
                  onPressed: () {
                    print('浏览游戏版本');
                  },
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 下载任务列表
    return WindowsCard(
      child: Column(
        children: filteredTasks.map((task) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _buildDownloadTaskItem(task, theme),
          );
        }).toList(),
      ),
    );
  }
  
  // 构建下载任务项
  Widget _buildDownloadTaskItem(DownloadTask task, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务标题和状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    _getStatusText(task.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(task.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildTaskActions(task, theme),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 进度条和信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${task.progress.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatSpeed(task.speed),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ETA: ${_formatTime(task.eta)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // 进度条
          LinearProgressIndicator(
            value: task.progress / 100,
            backgroundColor: theme.colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(task.status)),
            borderRadius: BorderRadius.circular(2),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
  
  // 构建任务操作按钮
  Widget _buildTaskActions(DownloadTask task, ThemeData theme) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return Row(
          children: [
            WindowsIconButton(
              icon: const Icon(Icons.pause, size: 16),
              onPressed: () => _pauseDownload(task),
              tooltip: '暂停',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.stop, size: 16),
              onPressed: () => _stopDownload(task),
              tooltip: '停止',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _deleteDownload(task),
              tooltip: '删除',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          children: [
            WindowsIconButton(
              icon: const Icon(Icons.play_arrow, size: 16),
              onPressed: () => _resumeDownload(task),
              tooltip: '继续',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.stop, size: 16),
              onPressed: () => _stopDownload(task),
              tooltip: '停止',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _deleteDownload(task),
              tooltip: '删除',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ],
        );
      case DownloadStatus.completed:
        return Row(
          children: [
            WindowsIconButton(
              icon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () => _openDownload(task),
              tooltip: '打开文件',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.replay, size: 16),
              onPressed: () => _retryDownload(task),
              tooltip: '重新下载',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _deleteDownload(task),
              tooltip: '删除',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ],
        );
      case DownloadStatus.failed:
        return Row(
          children: [
            WindowsIconButton(
              icon: const Icon(Icons.replay, size: 16),
              onPressed: () => _retryDownload(task),
              tooltip: '重试',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            WindowsIconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _deleteDownload(task),
              tooltip: '删除',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ],
        );
      default:
        return Row(
          children: [
            WindowsIconButton(
              icon: const Icon(Icons.cancel, size: 16),
              onPressed: () => _cancelDownload(task),
              tooltip: '取消',
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ],
        );
    }
  }
  
  // 构建现代化游戏版本项
  Widget _buildGameVersionItem(GameVersion version, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _downloadGameVersion(version);
        },
        onLongPress: () {
          _showGameVersionMenu(version);
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  // 版本类型图标
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getVersionTypeColor(version.type),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getVersionTypeIcon(version.type),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  
                  // 版本信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            version.version,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              fontFamily: 'NotoSansSC',
                            ),
                          ),
                          const SizedBox(width: 12),
                          // LTS标签
                          if (version.isLTS) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${version.tag} • 发布于 ${version.releaseTime}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${version.downloadCount.toStringAsFixed(0)} 次下载',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontFamily: 'NotoSansSC',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 下载按钮
              AnimeButton(
                text: '下载',
                onPressed: () {
                  _downloadGameVersion(version);
                },
                isPrimary: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 获取版本类型颜色
  Color _getVersionTypeColor(VersionType type) {
    switch (type) {
      case VersionType.release:
        return const Color(0xFF10B981);
      case VersionType.snapshot:
        return const Color(0xFF0078D4);
      case VersionType.beta:
        return const Color(0xFFF59E0B);
      case VersionType.alpha:
        return const Color(0xFFEF4444);
      case VersionType.special:
        return const Color(0xFF8B5CF6);
    }
  }
  
  // 获取版本类型图标
  IconData _getVersionTypeIcon(VersionType type) {
    switch (type) {
      case VersionType.release:
        return Icons.check_circle;
      case VersionType.snapshot:
        return Icons.timeline;
      case VersionType.beta:
        return Icons.bug_report;
      case VersionType.alpha:
        return Icons.question_mark;
      case VersionType.special:
        return Icons.star;
    }
  }
  
  // 获取状态文本
  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.queued:
        return '排队中';
      case DownloadStatus.downloading:
        return '下载中';
      case DownloadStatus.paused:
        return '已暂停';
      case DownloadStatus.completed:
        return '已完成';
      case DownloadStatus.failed:
        return '下载失败';
    }
  }
  
  // 获取状态颜色
  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.queued:
        return const Color(0xFFF59E0B);
      case DownloadStatus.downloading:
        return const Color(0xFF0078D4);
      case DownloadStatus.paused:
        return const Color(0xFF999999);
      case DownloadStatus.completed:
        return const Color(0xFF10B981);
      case DownloadStatus.failed:
        return const Color(0xFFEF4444);
    }
  }
  
  // 格式化速度
  String _formatSpeed(int speed) {
    if (speed < 1024) {
      return '${speed} B/s';
    } else if (speed < 1024 * 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }
  
  // 格式化时间
  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds 秒';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes 分 $remainingSeconds 秒';
    } else {
      final hours = seconds ~/ 3600;
      final remainingMinutes = (seconds % 3600) ~/ 60;
      return '$hours 小时 $remainingMinutes 分';
    }
  }
  
  // 下载游戏版本
  void _downloadGameVersion(GameVersion version) {
    print('下载游戏版本: ${version.version}');
    // TODO: 实现真实下载功能
  }
  
  // 显示游戏版本菜单
  void _showGameVersionMenu(GameVersion version) {
    print('显示游戏版本菜单: ${version.version}');
    // TODO: 实现右键菜单
  }
  
  // 暂停下载
  void _pauseDownload(DownloadTask task) {
    setState(() {
      task.status = DownloadStatus.paused;
      task.speed = 0;
    });
    print('暂停下载: ${task.name}');
  }
  
  // 恢复下载
  void _resumeDownload(DownloadTask task) {
    setState(() {
      task.status = DownloadStatus.downloading;
    });
    print('恢复下载: ${task.name}');
  }
  
  // 停止下载
  void _stopDownload(DownloadTask task) {
    setState(() {
      task.status = DownloadStatus.failed;
      task.speed = 0;
    });
    print('停止下载: ${task.name}');
  }
  
  // 取消下载
  void _cancelDownload(DownloadTask task) {
    setState(() {
      _downloadTasks.remove(task);
    });
    print('取消下载: ${task.name}');
  }
  
  // 删除下载
  void _deleteDownload(DownloadTask task) {
    setState(() {
      _downloadTasks.remove(task);
    });
    print('删除下载: ${task.name}');
  }
  
  // 重试下载
  void _retryDownload(DownloadTask task) {
    setState(() {
      task.status = DownloadStatus.downloading;
      task.progress = 0;
      task.speed = 2000000;
      task.eta = 200;
    });
    print('重试下载: ${task.name}');
  }
  
  // 打开下载文件
  void _openDownload(DownloadTask task) {
    print('打开下载文件: ${task.name}');
    // TODO: 实现打开文件功能
  }
  
  // 全部暂停
  void _pauseAllDownloads() {
    setState(() {
      for (var task in _downloadTasks) {
        if (task.status == DownloadStatus.downloading) {
          task.status = DownloadStatus.paused;
          task.speed = 0;
        }
      }
    });
    print('全部暂停');
  }
  
  // 全部删除
  void _deleteAllDownloads() {
    setState(() {
      _downloadTasks.clear();
    });
    print('全部删除');
  }
}
