import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bamclauncher/components/anime_button.dart';
import 'package:bamclauncher/components/anime_card.dart';
import 'package:bamclauncher/models/instance_model.dart';
import 'package:bamclauncher/services/instance_manager.dart';
import 'package:bamclauncher/utils/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';

// 实例详情页
class InstanceDetailView extends StatefulWidget {
  final String instanceId;
  
  const InstanceDetailView({
    super.key,
    required this.instanceId,
  });
  
  @override
  State<InstanceDetailView> createState() => _InstanceDetailViewState();
}

class _InstanceDetailViewState extends State<InstanceDetailView> {
  final InstanceManager _instanceManager = InstanceManager();
  InstanceModel? _instance;
  bool _isLoading = true;
  bool _isLaunching = false;
  
  @override
  void initState() {
    super.initState();
    _loadInstance();
  }
  
  // 加载实例信息
  Future<void> _loadInstance() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final instance = await _instanceManager.getInstance(widget.instanceId);
      if (mounted) {
        setState(() {
          _instance = instance;
        });
      }
    } catch (e) {
      logE('Failed to load instance:', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载实例失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // 启动实例
  Future<void> _launchInstance() async {
    if (_instance == null) return;
    
    setState(() {
      _isLaunching = true;
    });
    
    try {
      await _instanceManager.launchInstance(_instance!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('实例启动成功')),
        );
      }
    } catch (e) {
      logE('Failed to launch instance:', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动实例失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }
  
  // 删除实例
  Future<void> _deleteInstance() async {
    if (_instance == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除实例'),
          content: Text('确定要删除实例 "${_instance!.name}" 吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    
    if (confirm == true) {
      try {
        await _instanceManager.deleteInstance(widget.instanceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('实例删除成功')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        logE('Failed to delete instance:', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除实例失败: $e')),
          );
        }
      }
    }
  }
  
  // 编辑实例
  Future<void> _editInstance() async {
    if (_instance == null) return;
    
    final TextEditingController nameController = TextEditingController(text: _instance!.name);
    final TextEditingController mcVersionController = TextEditingController(text: _instance!.minecraftVersion);
    final TextEditingController loaderTypeController = TextEditingController(text: _instance!.loaderType);
    final TextEditingController loaderVersionController = TextEditingController(text: _instance!.loaderVersion);
    final TextEditingController javaPathController = TextEditingController(text: _instance!.javaPath);
    final TextEditingController memoryController = TextEditingController(text: _instance!.allocatedMemory.toString());
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑实例'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '实例名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mcVersionController,
                  decoration: const InputDecoration(
                    labelText: 'Minecraft版本',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: loaderTypeController,
                  decoration: const InputDecoration(
                    labelText: '加载器类型',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: loaderVersionController,
                  decoration: const InputDecoration(
                    labelText: '加载器版本',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: javaPathController,
                  decoration: const InputDecoration(
                    labelText: 'Java路径',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // Java路径暂时不可编辑，后续可添加选择功能
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: memoryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '分配内存 (MB)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      try {
        final updatedInstance = _instance!.copyWith(
          name: nameController.text,
          minecraftVersion: mcVersionController.text,
          loaderType: loaderTypeController.text,
          loaderVersion: loaderVersionController.text,
          javaPath: javaPathController.text,
          allocatedMemory: int.tryParse(memoryController.text) ?? 2048,
          updatedAt: DateTime.now(),
        );
        
        await _instanceManager.updateInstance(updatedInstance);
        await _loadInstance();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('实例更新成功')),
        );
      } catch (e) {
        logE('Failed to update instance:', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新实例失败: $e')),
        );
      }
    }
  }
  
  // 备份实例
  Future<void> _backupInstance() async {
    if (_instance == null) return;
    
    try {
      final instanceDir = Directory(_instance!.instanceDir);
      if (!instanceDir.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('实例目录不存在')),
        );
        return;
      }
      
      // 获取备份目录
      final backupDir = Directory('${instanceDir.path}/backups');
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }
      
      // 生成备份文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupName = '${_instance!.name}_$timestamp.zip';
      
      // 显示备份进度
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('开始备份实例: ${_instance!.name}')),
      );
      
      // 实现实例备份逻辑
      // 1. 创建备份目录
      final backupDirectory = Directory('${_instance!.instanceDir}/backups');
      if (!backupDirectory.existsSync()) {
        backupDirectory.createSync(recursive: true);
      }
      
      // 2. 创建zip文件
      final zipFile = File('${backupDirectory.path}/$backupName');
      
      // 3. 创建Archive对象
      final archive = Archive();
      
      // 4. 遍历实例目录，添加所有文件到archive
      final instanceDirectory = Directory(_instance!.instanceDir);
      final files = instanceDirectory.listSync(recursive: true);
      
      for (final file in files) {
        if (file is File) {
          // 跳过备份目录本身
          if (file.path.startsWith(backupDirectory.path)) {
            continue;
          }
          
          // 读取文件内容
          final bytes = await file.readAsBytes();
          
          // 创建ArchiveFile
          final relativePath = file.path.replaceFirst('${instanceDirectory.path}/', '');
          final archiveFile = ArchiveFile(relativePath, bytes.length, bytes);
          
          // 添加到archive
          archive.addFile(archiveFile);
        }
      }
      
      // 5. 压缩并写入文件
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await zipFile.writeAsBytes(zipBytes);
      }
      
      // 6. 验证备份文件是否创建成功
      if (zipFile.existsSync()) {
        logI('实例备份成功: ${zipFile.path}');
      } else {
        throw Exception('备份文件创建失败');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份成功: $backupName')),
      );
    } catch (e) {
      logE('备份实例失败:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份失败: $e')),
      );
    }
  }
  
  // 导入Mod
  Future<void> _importMod() async {
    if (_instance == null) return;
    
    try {
      // 打开文件选择对话框
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jar'],
        dialogTitle: '选择Mod文件',
      );
      
      if (result == null || result.files.isEmpty) {
        return; // 用户取消选择
      }
      
      // 获取Mods目录
      final modsDir = Directory('${_instance!.instanceDir}/mods');
      if (!modsDir.existsSync()) {
        modsDir.createSync(recursive: true);
      }
      
      // 复制选中的Mod文件到Mods目录
      int successCount = 0;
      int failCount = 0;
      
      for (final file in result.files) {
        final sourceFile = File(file.path!);
        final destFile = File('${modsDir.path}/${file.name}');
        
        try {
          await sourceFile.copy(destFile.path);
          successCount++;
        } catch (e) {
          logE('复制Mod失败: ${file.name}', e);
          failCount++;
        }
      }
      
      // 显示导入结果
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入完成: 成功 $successCount 个, 失败 $failCount 个'),
          ),
        );
      }
    } catch (e) {
      logE('导入Mod失败:', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入Mod失败: $e')),
        );
      }
    }
  }
  
  // 管理资源包
  Future<void> _manageResourcePacks() async {
    if (_instance == null) return;
    
    // 获取资源包目录
    final resourcepacksDir = Directory('${_instance!.instanceDir}/resourcepacks');
    if (!resourcepacksDir.existsSync()) {
      resourcepacksDir.createSync(recursive: true);
    }
    
    // 列出当前资源包
    final resourcepacks = resourcepacksDir.listSync().where((entity) {
      return entity is File && 
             (entity.path.endsWith('.zip') || 
              entity.path.endsWith('.rar') || 
              entity.path.endsWith('.7z'));
    }).toList();
    
    // 实现资源包管理界面
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ResourcePackManagementDialog(
          instance: _instance!,
          resourcepacks: resourcepacks.whereType<File>().toList(),
        ),
      );
    }
  }
  
  // 配置Java
  Future<void> _configureJava() async {
    if (_instance == null) return;
    
    try {
      // 检测系统中已安装的Java版本
      final javaVersions = await _detectJavaVersions();
      
      // 显示Java配置对话框
      await showDialog(
        context: context,
        builder: (context) => JavaConfigurationDialog(
          instance: _instance!,
          detectedJavaVersions: javaVersions,
          onSave: (javaPath) async {
            // 保存Java配置到实例设置中
            await _instanceManager.updateInstance(
              _instance!.copyWith(javaPath: javaPath),
            );
            
            setState(() {
              _instance = _instance!.copyWith(javaPath: javaPath);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Java配置已更新')),
            );
          },
        ),
      );
    } catch (e) {
      logE('配置Java失败:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('配置Java失败: $e')),
      );
    }
  }
  
  // 检测系统中已安装的Java版本
  Future<List<Map<String, String>>> _detectJavaVersions() async {
    final javaVersions = <Map<String, String>>[];
    
    try {
      // 尝试检测系统Java
      final result = await Process.run('java', ['-version'], runInShell: true);
      if (result.exitCode == 0) {
        // 解析Java版本信息
        final errorOutput = result.stderr.toString();
        final versionMatch = RegExp(r'version "(.*?)"').firstMatch(errorOutput);
        if (versionMatch != null) {
          javaVersions.add({
            'path': 'java',
            'version': versionMatch.group(1) ?? '未知版本',
          });
        }
      }
      
      // 尝试检测常见Java安装路径
      final commonPaths = Platform.isWindows
          ? [
              'C:\\Program Files\\Java',
              'C:\\Program Files (x86)\\Java',
            ]
          : [
              '/usr/lib/jvm',
              '/usr/local/java',
              '/opt/java',
            ];
      
      for (final path in commonPaths) {
        final javaDir = Directory(path);
        if (javaDir.existsSync()) {
          final subDirs = javaDir.listSync().whereType<Directory>().toList();
          for (final subDir in subDirs) {
            final javaExec = Platform.isWindows
                ? '${subDir.path}\\bin\\java.exe'
                : '${subDir.path}/bin/java';
            
            if (File(javaExec).existsSync()) {
              try {
                final result = await Process.run(javaExec, ['-version'], runInShell: true);
                if (result.exitCode == 0) {
                  final errorOutput = result.stderr.toString();
                  final versionMatch = RegExp(r'version "(.*?)"').firstMatch(errorOutput);
                  if (versionMatch != null) {
                    javaVersions.add({
                      'path': javaExec,
                      'version': versionMatch.group(1) ?? '未知版本',
                    });
                  }
                }
              } catch (e) {
                // 忽略无法执行的Java路径
              }
            }
          }
        }
      }
    } catch (e) {
      logE('检测Java版本失败:', e);
    }
    
    return javaVersions;
  }
  
  // 打开实例文件夹
  Future<void> _openInstanceFolder() async {
    if (_instance == null) return;
    
    try {
      final instanceDir = Directory(_instance!.instanceDir);
      if (!instanceDir.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('实例目录不存在')),
        );
        return;
      }
      
      // 使用系统命令打开文件资源管理器
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [instanceDir.path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [instanceDir.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [instanceDir.path]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前平台不支持打开文件夹')),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已打开实例文件夹')),
      );
    } catch (e) {
      logE('打开实例文件夹失败:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开实例文件夹失败: $e')),
      );
    }
  }
  
  // 修改内存设置
  Future<void> _modifyMemorySetting() async {
    if (_instance == null) return;
    
    final TextEditingController memoryController = TextEditingController(text: _instance!.allocatedMemory.toString());
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改内存设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请输入分配给实例的内存大小 (MB):'),
              const SizedBox(height: 16),
              TextField(
                controller: memoryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '内存大小 (MB)',
                  border: OutlineInputBorder(),
                  hintText: '例如: 2048',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '建议值: 2048-8192 MB',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      try {
        final newMemory = int.tryParse(memoryController.text);
        if (newMemory == null || newMemory <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入有效的内存大小')),
          );
          return;
        }
        
        // 更新实例内存设置
        final updatedInstance = _instance!.copyWith(
          allocatedMemory: newMemory,
          updatedAt: DateTime.now(),
        );
        
        await _instanceManager.updateInstance(updatedInstance);
        await _loadInstance();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('内存设置已更新为 $newMemory MB')),
        );
      } catch (e) {
        logE('修改内存设置失败:', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('修改内存设置失败: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('实例详情'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_instance == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('实例详情'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('实例不存在或已被删除'),
              const SizedBox(height: 16),
              AnimeButton(
                text: '返回',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
    
    // 使用局部变量避免重复的非空断言
    final instance = _instance!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(instance.name),
        actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editInstance(),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteInstance(),
              color: Colors.red,
            ),
          ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 实例基本信息卡片
            const AnimeCard(
              title: '基本信息',
              subtitle: '',
              icon: Icon(
                Icons.info_outline,
                size: 40,
                color: Color(0xFF3B82F6),
              ),
              onTap: null,
            ),
            const SizedBox(height: 16),
            
            // 实例详情信息
            _buildInstanceInfo(context),
            const SizedBox(height: 24),
            
            // 启动按钮
            SizedBox(
              width: double.infinity,
              child: AnimeButton(
                text: _isLaunching ? '启动中...' : '启动实例',
                onPressed: _isLaunching ? null : _launchInstance,
                isPrimary: true,
                leadingIcon: const Icon(Icons.play_arrow),
              ),
            ),
            const SizedBox(height: 24),
            
            // 管理选项
            const Text(
              '管理选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AnimeButton(
                    text: '备份实例',
                    onPressed: () => _backupInstance(),
                    isPrimary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leadingIcon: const Icon(Icons.backup),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimeButton(
                    text: '导入Mod',
                    onPressed: () => _importMod(),
                    isPrimary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leadingIcon: const Icon(Icons.file_upload),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AnimeButton(
                    text: '管理资源包',
                    onPressed: () => _manageResourcePacks(),
                    isPrimary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leadingIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimeButton(
                    text: '配置Java',
                    onPressed: () => _configureJava(),
                    isPrimary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leadingIcon: const Icon(Icons.settings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 实例文件夹信息
            AnimeCard(
              title: '实例文件夹',
              subtitle: instance.instanceDir,
              icon: const Icon(
                Icons.folder,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
              onTap: () => _openInstanceFolder(),
            ),
            const SizedBox(height: 16),
            
            // 版本信息
            AnimeCard(
              title: '版本信息',
              subtitle: 'Minecraft ${instance.minecraftVersion} - ${instance.loaderType} ${instance.loaderVersion}',
              icon: const Icon(
                Icons.code,
                size: 40,
                color: Color(0xFF34D399),
              ),
              onTap: null,
            ),
            const SizedBox(height: 16),
            
            // 内存设置
            AnimeCard(
              title: '内存设置',
              subtitle: '分配内存: ${instance.allocatedMemory}MB',
              icon: const Icon(
                Icons.memory,
                size: 40,
                color: Color(0xFFF472B6),
              ),
              onTap: () => _modifyMemorySetting(),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建实例详情信息
  Widget _buildInstanceInfo(BuildContext context) {
    if (_instance == null) return const SizedBox();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Minecraft版本', _instance!.minecraftVersion),
          _buildDivider(),
          _buildInfoRow('加载器类型', _instance!.loaderType),
          _buildDivider(),
          _buildInfoRow('加载器版本', _instance!.loaderVersion),
          _buildDivider(),
          _buildInfoRow('Java路径', _instance!.javaPath.isEmpty ? '自动检测' : _instance!.javaPath),
          _buildDivider(),
          _buildInfoRow('分配内存', '${_instance!.allocatedMemory}MB'),
          _buildDivider(),
          _buildInfoRow('实例ID', _instance!.id),
          _buildDivider(),
          _buildInfoRow('创建时间', _formatDate(_instance!.createdAt)),
          _buildDivider(),
          _buildInfoRow('更新时间', _formatDate(_instance!.updatedAt)),
        ],
      ),
    );
  }
  
  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建分割线
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE5E7EB),
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Java配置对话框
class JavaConfigurationDialog extends StatefulWidget {
  final InstanceModel instance;
  final List<Map<String, String>> detectedJavaVersions;
  final Function(String) onSave;
  
  const JavaConfigurationDialog({
    super.key,
    required this.instance,
    required this.detectedJavaVersions,
    required this.onSave,
  });
  
  @override
  State<JavaConfigurationDialog> createState() => _JavaConfigurationDialogState();
}

class _JavaConfigurationDialogState extends State<JavaConfigurationDialog> {
  String _selectedJavaPath = '';
  
  @override
  void initState() {
    super.initState();
    _selectedJavaPath = widget.instance.javaPath;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 对话框标题
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Java配置',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // 检测到的Java版本列表
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '检测到的Java版本',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  widget.detectedJavaVersions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '未检测到Java，请手动选择Java路径',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : Column(
                          children: widget.detectedJavaVersions.map((java) {
                            return RadioListTile<String>(
                              title: Text(
                                'Java ${java['version']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                java['path'] ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              value: java['path'] ?? '',
                              // ignore: deprecated_member_use
                              groupValue: _selectedJavaPath,
                              // ignore: deprecated_member_use
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedJavaPath = value;
                                  });
                                }
                              },
                              activeColor: const Color(0xFF667eea),
                              tileColor: const Color(0xFF16213e),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          }).toList(),
                        ),
                  
                  // 手动选择Java路径
                  const SizedBox(height: 20),
                  const Text(
                    '手动选择Java路径',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _selectedJavaPath,
                          onChanged: (value) {
                            setState(() {
                              _selectedJavaPath = value;
                            });
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Java路径',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF16213e),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF303f9f)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF303f9f)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectJavaPath,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('浏览'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_selectedJavaPath);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 选择Java路径
  Future<void> _selectJavaPath() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: '选择Java可执行文件',
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedJavaPath = result.files.first.path!;
        });
      }
    } catch (e) {
      logE('选择Java路径失败:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择Java路径失败: $e')),
      );
    }
  }
}

// 资源包管理对话框
class ResourcePackManagementDialog extends StatefulWidget {
  final InstanceModel instance;
  final List<File> resourcepacks;
  
  const ResourcePackManagementDialog({
    super.key,
    required this.instance,
    required this.resourcepacks,
  });
  
  @override
  State<ResourcePackManagementDialog> createState() => _ResourcePackManagementDialogState();
}

class _ResourcePackManagementDialogState extends State<ResourcePackManagementDialog> {
  late List<File> _resourcepacks;
  
  @override
  void initState() {
    super.initState();
    _resourcepacks = List.from(widget.resourcepacks);
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // 对话框标题
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '资源包管理',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // 资源包列表
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _resourcepacks.isEmpty
                    ? const Center(
                        child: Text(
                          '当前没有资源包',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _resourcepacks.length,
                        itemBuilder: (context, index) {
                          final resourcepack = _resourcepacks[index];
                          return Card(
                            color: const Color(0xFF16213e),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                resourcepack.path.split(Platform.pathSeparator).last,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${(resourcepack.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFE53935)),
                                    onPressed: () => _deleteResourcePack(resourcepack),
                                    tooltip: '删除',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            
            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addResourcePack,
                    icon: const Icon(Icons.add),
                    label: const Text('添加资源包'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 添加资源包
  Future<void> _addResourcePack() async {
    try {
      // 打开文件选择对话框
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z'],
        allowMultiple: true,
      );
      
      if (result == null || result.files.isEmpty) return;
      
      // 获取资源包目录
      final resourcepacksDir = Directory('${widget.instance.instanceDir}/resourcepacks');
      if (!resourcepacksDir.existsSync()) {
        resourcepacksDir.createSync(recursive: true);
      }
      
      // 复制选中的资源包文件到资源包目录
      int successCount = 0;
      
      for (final file in result.files) {
        final sourceFile = File(file.path!);
        final destFile = File('${resourcepacksDir.path}/${file.name}');
        
        try {
          await sourceFile.copy(destFile.path);
          successCount++;
          setState(() {
            _resourcepacks.add(destFile);
          });
        } catch (e) {
          logE('复制资源包失败: ${file.name}', e);
        }
      }
      
      // 显示添加结果
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功添加 $successCount 个资源包')),
        );
      }
    } catch (e) {
      logE('添加资源包失败:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加资源包失败: $e')),
      );
    }
  }
  
  // 删除资源包
  void _deleteResourcePack(File resourcepack) {
    final fileName = resourcepack.path.split(Platform.pathSeparator).last;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除资源包 "$fileName" 吗？',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              try {
                resourcepack.deleteSync();
                setState(() {
                  _resourcepacks.remove(resourcepack);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('资源包 "$fileName" 已删除')),
                );
              } catch (e) {
                logE('删除资源包失败:', e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除资源包失败: $e')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }
}
