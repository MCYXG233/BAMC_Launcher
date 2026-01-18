import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bamclauncher/components/windows_button.dart';
import 'package:bamclauncher/components/windows_card.dart';
import 'package:bamclauncher/models/instance_model.dart';
import 'package:bamclauncher/services/instance_manager.dart';
import 'package:bamclauncher/services/service_locator.dart';
import 'package:bamclauncher/utils/logger.dart';
import 'package:bamclauncher/views/instance/instance_detail_view.dart';
import 'package:file_picker/file_picker.dart';

// 我的实例列表页面
class InstanceListView extends StatefulWidget {
  const InstanceListView({super.key});

  @override
  State<InstanceListView> createState() => _InstanceListViewState();
}

class _InstanceListViewState extends State<InstanceListView> {
  // 使用InstanceManager服务
  final InstanceManager _instanceManager = serviceLocator.get<InstanceManager>();
  
  // 真实实例数据列表
  List<InstanceModel> _instances = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInstances();
  }

  // 从服务加载实例数据
  Future<void> _loadInstances() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final instances = await _instanceManager.getAllInstances();
      setState(() {
        _instances = instances;
      });
    } catch (e) {
      print('加载实例失败: $e');
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('加载实例失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  // 刷新实例列表
  Future<void> _refreshInstances() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadInstances();
  }

  // 启动实例
  Future<void> _launchInstance(InstanceModel instance) async {
    final theme = Theme.of(context);
    try {
      await _instanceManager.launchInstance(instance);
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在启动实例: ${instance.name}'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      logE('启动实例失败: $e');
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('启动实例失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 导入整合包
  Future<void> _importPack() async {
    final theme = Theme.of(context);
    try {
      // 实现文件选择对话框
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bamcpack', 'pclpack', 'mrpack', 'zip', '7z'],
        dialogTitle: '选择整合包文件',
      );
      
      if (result == null || result.files.isEmpty) {
        return; // 用户取消选择
      }
      
      final packPath = result.files.first.path!;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在导入整合包...'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }
      
      // 调用InstanceManager的导入方法
      final instance = await _instanceManager.importFromPack(packPath);
      
      // 重新加载实例列表
      await _loadInstances();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('整合包导入成功: ${instance.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logE('整合包导入失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('整合包导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 导出整合包
  Future<void> _exportPack(InstanceModel instance) async {
    final theme = Theme.of(context);
    try {
      // 选择保存位置
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '选择整合包保存位置',
        fileName: '${instance.name}.bamcpack',
        allowedExtensions: ['bamcpack'],
        type: FileType.custom,
      );
      
      if (outputPath == null) {
        return; // 用户取消选择
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在导出整合包...'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }
      
      // 调用InstanceManager的导出方法
      await _instanceManager.exportToPack(instance, outputPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('整合包导出成功: $outputPath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logE('整合包导出失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('整合包导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      // Windows风格的AppBar，使用主题颜色和圆角
      appBar: AppBar(
        title: const Text('我的实例'),
        elevation: 1,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: _refreshInstances,
            tooltip: '刷新实例列表',
          ),
        ],
      ),
      // 使用主题背景色
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // 操作按钮区 - 放置在顶部，更符合桌面软件习惯
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                WindowsButton(
                  text: '新建实例',
                  onPressed: () {
                    print('新建实例');
                    // TODO: 实现新建实例功能
                  },
                  leadingIcon: const Icon(Icons.add, size: 18),
                  height: 36,
                ),
                const SizedBox(width: 8),
                WindowsButton(
                  text: '导入整合包',
                  onPressed: _importPack,
                  leadingIcon: const Icon(Icons.upload_file, size: 18),
                  isPrimary: false,
                  height: 36,
                ),
                const SizedBox(width: 8),
                WindowsButton(
                  text: '扫描实例',
                  onPressed: () {
                    print('扫描实例');
                    // TODO: 实现扫描实例功能
                  },
                  leadingIcon: const Icon(Icons.search, size: 18),
                  isPrimary: false,
                  height: 36,
                ),
              ],
            ),
          ),
          
          // 实例列表区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _isLoading ? 
                // 加载状态
                Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ) : _instances.isEmpty ? 
                // 空状态
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gamepad_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无实例',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击上方按钮新建实例或导入整合包',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ) : 
                // 实例列表 - 使用RefreshIndicator支持下拉刷新
                RefreshIndicator(
                  onRefresh: _refreshInstances,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                            leading: Container(
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
                            title: Text(
                              instance.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Minecraft ${instance.minecraftVersion} - ${instance.loaderType} ${instance.loaderVersion}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () {
                              // 跳转到实例详情页
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InstanceDetailView(
                                    instanceId: instance.id,
                                  ),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                WindowsIconButton(
                                  icon: Icon(Icons.play_arrow, size: 20),
                                  onPressed: () => _launchInstance(instance),
                                  tooltip: '启动实例',
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                WindowsIconButton(
                                  icon: Icon(Icons.download, size: 20),
                                  onPressed: () => _exportPack(instance),
                                  tooltip: '导出整合包',
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                WindowsIconButton(
                                  icon: Icon(Icons.settings, size: 20),
                                  onPressed: () {
                                    // 跳转到实例设置页
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InstanceDetailView(
                                          instanceId: instance.id,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: '实例设置',
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

