import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:bamclauncher/components/anime_button.dart';
import 'package:bamclauncher/components/anime_card.dart';
import 'package:bamclauncher/services/pack_format_detector.dart';
import 'package:bamclauncher/services/bamc_pack_compressor.dart';
import 'package:bamclauncher/utils/file_path_utils.dart';
import 'package:bamclauncher/utils/logger.dart';
import 'package:file_picker/file_picker.dart';

// 整合包管理页面（导入和创建）
class PackManagementView extends StatefulWidget {
  const PackManagementView({super.key});
  
  @override
  State<PackManagementView> createState() => _PackManagementViewState();
}

class _PackManagementViewState extends State<PackManagementView> {
  final PackFormatDetector _packFormatDetector = PackFormatDetector();
  final BamcPackCompressor _bamcPackCompressor = BamcPackCompressor();
  
  bool _isImporting = false;
  bool _isCreating = false;
  String _selectedPackPath = '';
  PackFormat _detectedFormat = PackFormat.unknown;
  
  // 游戏版本选项
  final List<String> _gameVersions = [
    '1.20.4',
    '1.20.1',
    '1.19.4',
    '1.19.2',
    '1.18.2',
    '1.17.1',
    '1.16.5',
  ];
  
  // 加载器类型选项
  final List<String> _loaderTypes = [
    'fabric',
    'forge',
    'quilt',
    'vanilla',
  ];
  
  // 表单数据
  String _selectedGameVersion = '1.20.4';
  String _selectedLoaderType = 'fabric';
  String _packName = '';
  String _packDescription = '';
  
  // 导入整合包
  Future<void> _importPack() async {
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
    
    setState(() {
      _isImporting = true;
      _selectedPackPath = packPath;
    });
    
    try {
      // 检测整合包格式
      final format = await _packFormatDetector.detectFormat(packPath);
      setState(() {
        _detectedFormat = format;
      });
      
      logI('Detected pack format: $format');
      
      // 根据格式导入整合包
      await _importPackByFormat(packPath, format);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('整合包导入成功')),
        );
      }
    } catch (e) {
      logE('Failed to import pack:', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('整合包导入失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
  
  // 创建整合包
  Future<void> _createPack() async {
    if (_packName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入整合包名称')),
      );
      return;
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      // 1. 选择保存位置
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '选择整合包保存位置',
        fileName: '$_packName.bamcpack',
        allowedExtensions: ['bamcpack'],
        type: FileType.custom,
      );
      
      if (outputPath == null) {
        return; // 用户取消选择
      }
      
      // 2. 创建临时工作目录
      final tempDir = await Directory.systemTemp.createTemp('bamcpack_');
      final tempPath = tempDir.path;
      
      try {
        // 3. 创建整合包结构
        await _createPackStructure(tempPath);
        
        // 4. 压缩为.bamcpack格式
        await _bamcPackCompressor.compress(tempPath, outputPath);
        
        logI('Creating pack: $_packName');
        logI('Game version: $_selectedGameVersion');
        logI('Loader type: $_selectedLoaderType');
        logI('Description: $_packDescription');
        logI('Pack saved to: $outputPath');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('整合包创建成功: $outputPath')),
          );
          
          // 5. 重置表单
          setState(() {
            _packName = '';
            _packDescription = '';
            _selectedGameVersion = '1.20.4';
            _selectedLoaderType = 'fabric';
          });
        }
      } finally {
        // 清理临时目录
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      logE('Failed to create pack:', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('整合包创建失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
  
  // 创建整合包结构
  Future<void> _createPackStructure(String tempPath) async {
    // 创建整合包元数据文件
    final metadata = {
      'name': _packName,
      'description': _packDescription,
      'gameVersion': _selectedGameVersion,
      'loaderType': _selectedLoaderType,
      'loaderVersion': 'latest',
      'author': 'BAMCLauncher',
      'version': '1.0.0',
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    final metadataFile = File('$tempPath/metadata.json');
    await metadataFile.writeAsString(jsonEncode(metadata));
    
    // 创建实例配置文件
    final instanceConfig = {
      'id': 'temp_instance',
      'name': _packName,
      'minecraftVersion': _selectedGameVersion,
      'loaderType': _selectedLoaderType,
      'loaderVersion': 'latest',
      'javaPath': '',
      'allocatedMemory': 2048,
      'jvmArguments': [],
      'gameArguments': [],
      'instanceDir': tempPath,
      'userId': 'temp_user',
      'accessToken': 'temp_token',
      'userType': 'mojang',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': false,
    };
    
    final instanceFile = File('$tempPath/instance.json');
    await instanceFile.writeAsString(jsonEncode(instanceConfig));
    
    // 创建必要的子目录
    final subDirs = ['mods', 'resourcepacks', 'saves', 'config', 'assets', 'libraries', 'logs'];
    for (final subDir in subDirs) {
      final dir = Directory('$tempPath/$subDir');
      await dir.create();
    }
    
    logI('Pack structure created at: $tempPath');
  }
  
  // 压缩为.bamcpack格式
  Future<void> _compressToBamcPack() async {
    // 实现文件夹选择对话框
    final sourceDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择要压缩的实例文件夹',
    );
    
    if (sourceDir == null) {
      return; // 用户取消选择
    }
    
    // 实现文件保存对话框
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存位置',
      fileName: 'example.bamcpack',
      allowedExtensions: ['bamcpack'],
      type: FileType.custom,
    );
    
    if (outputPath == null) {
      return; // 用户取消选择
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      // 使用BamcPackCompressor压缩文件
      await _bamcPackCompressor.compress(sourceDir, outputPath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('.bamcpack压缩成功')),
      );
    } catch (e) {
      logE('Failed to compress to bamcpack:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('.bamcpack压缩失败: $e')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
  
  // 根据格式导入整合包
  Future<void> _importPackByFormat(String packPath, PackFormat format) async {
    // 获取实例目录
    final instancesDir = await _getInstancesDirectory();
    
    // 生成实例名称和目录
    final instanceName = _generateInstanceNameFromPack(packPath);
    final instanceDir = '$instancesDir/$instanceName';
    
    logI('Importing pack to: $instanceDir');
    
    switch (format) {
      case PackFormat.bamcpack:
        // 使用BamcPackCompressor解压.bamcpack格式
        await _bamcPackCompressor.decompress(packPath, instanceDir);
        break;
        
      case PackFormat.pclpack:
        // 实现PCLPack格式的导入
        logI('Importing PCLPack format');
        // 假设PCLPack是zip格式，使用默认解压
        await _extractZipFile(packPath, instanceDir);
        break;
        
      case PackFormat.mrpack:
        // 实现MRPack格式的导入
        logI('Importing MRPack format');
        // 假设MRPack是zip格式，使用默认解压
        await _extractZipFile(packPath, instanceDir);
        break;
        
      case PackFormat.mcbbs:
        // 实现MCBBS格式的导入
        logI('Importing MCBBS format');
        // 假设MCBBS是zip或7z格式，使用默认解压
        await _extractZipFile(packPath, instanceDir);
        break;
        
      default:
        throw Exception('Unsupported pack format: $format');
    }
    
    // 创建实例配置文件
    await _createInstanceConfigFile(instanceDir, instanceName);
    
    logI('Pack imported successfully to: $instanceDir');
  }
  
  // 创建实例配置文件
  Future<void> _createInstanceConfigFile(String instanceDir, String instanceName) async {
    try {
      // 检查是否存在metadata.json文件
      final metadataFile = File('$instanceDir/metadata.json');
      Map<String, dynamic> metadata = {};
      
      if (metadataFile.existsSync()) {
        // 读取metadata.json文件
        final metadataContent = await metadataFile.readAsString();
        metadata = jsonDecode(metadataContent);
      }
      
      // 创建实例配置
      final instanceConfig = {
        'id': instanceName,
        'name': metadata['name'] ?? instanceName,
        'minecraftVersion': metadata['gameVersion'] ?? '1.20.4',
        'loaderType': metadata['loaderType'] ?? 'vanilla',
        'loaderVersion': metadata['loaderVersion'] ?? 'latest',
        'javaPath': '',
        'allocatedMemory': 2048,
        'jvmArguments': [],
        'gameArguments': [],
        'instanceDir': instanceDir,
        'iconPath': '',
        'isActive': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'userId': '',
        'accessToken': '',
        'userType': 'offline',
        'isCrashed': false,
        'crashReason': '',
        'lastCrashTime': null,
        'gameErrors': [],
        'onlinePlayers': [],
        'serverAddress': '',
        'isConnectedToServer': false,
        'isGameReady': false,
        'lastReadyTime': null,
        'resourceLoadingProgress': 0.0,
      };
      
      // 写入instance.json文件
      final instanceConfigFile = File('$instanceDir/instance.json');
      await instanceConfigFile.writeAsString(jsonEncode(instanceConfig));
      
      logI('Instance config file created successfully: ${instanceConfigFile.path}');
    } catch (e) {
      logE('Failed to create instance config file:', e);
      throw Exception('Failed to create instance config file: $e');
    }
  }
  
  // 获取实例目录
  Future<String> _getInstancesDirectory() async {
    return await FilePathUtils.getInstancesDirectory();
  }
  
  // 从整合包路径生成实例名称
  String _generateInstanceNameFromPack(String packPath) {
    // 提取文件名（不包含扩展名）
    final fileName = packPath.split(Platform.pathSeparator).last;
    final nameWithoutExtension = fileName.split('.').first;
    
    // 添加时间戳避免重名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$nameWithoutExtension$timestamp';
  }
  
  // 解压zip文件
  Future<void> _extractZipFile(String zipPath, String destDir) async {
    try {
      // 使用archive库解压文件
      final zipFile = File(zipPath);
      final bytes = await zipFile.readAsBytes();
      
      // 尝试使用ZipDecoder解压
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // 创建目标目录
      final destination = Directory(destDir);
      if (!destination.existsSync()) {
        destination.createSync(recursive: true);
      }
      
      // 解压所有文件
      for (final file in archive.files) {
        if (file.isFile) {
          final filePath = '$destDir/${file.name}';
          final outputFile = File(filePath);
          
          // 创建父目录
          final parentDir = outputFile.parent;
          if (!parentDir.existsSync()) {
            parentDir.createSync(recursive: true);
          }
          
          // 写入文件
          await outputFile.writeAsBytes(file.content as List<int>);
        }
      }
      
      logI('Successfully extracted $zipPath to $destDir');
    } catch (e) {
      logE('Failed to extract $zipPath:', e);
      // 可以尝试其他解压方法，比如使用7z或系统命令
      rethrow;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Windows风格的AppBar
      appBar: AppBar(
        title: const Text('整合包管理'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      // 纯色背景，更符合Windows桌面软件风格
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            const Text(
              '整合包导入与创建',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '支持多种整合包格式，一键导入或创建属于你的整合包',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6E6E6E),
              ),
            ),
            const SizedBox(height: 24),
            
            // 操作按钮区 - 顶部放置，更符合桌面软件习惯
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : _importPack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.upload_file, size: 18),
                          const SizedBox(width: 6),
                          Text(_isImporting ? '导入中...' : '导入整合包'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : () => _createPack(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 18),
                          const SizedBox(width: 6),
                          Text(_isCreating ? '创建中...' : '创建整合包'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: _isCreating ? null : () => _compressToBamcPack(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0078D4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        side: const BorderSide(color: Color(0xFF0078D4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.compress, size: 18),
                          const SizedBox(width: 6),
                          Text(_isCreating ? '压缩中...' : '压缩为 .bamcpack'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 导入状态显示
            if (_isImporting) ...[
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFE0E0E0),
                color: Color(0xFF0078D4),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '正在导入: $_selectedPackPath',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E6E6E),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 检测到的格式显示
            if (_detectedFormat != PackFormat.unknown) ...[
              const SizedBox(height: 8),
              Text(
                '检测到格式: ${_detectedFormat.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0078D4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 创建整合包表单 - Windows风格卡片
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 表单标题
                  const Text(
                    '创建新整合包',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 创建整合包表单
                  _buildCreatePackForm(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 支持的格式说明
            const Text(
              '支持的整合包格式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            
            // 格式列表 - Windows风格标签
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFormatChip('.bamcpack', 'BAMCLauncher 专有格式', const Color(0xFF0078D4)),
                _buildFormatChip('.pclpack', 'PCL 启动器格式', const Color(0xFFF59E0B)),
                _buildFormatChip('.mrpack', 'Modrinth 格式', const Color(0xFF10B981)),
                _buildFormatChip('.zip/.7z', '传统压缩包格式', const Color(0xFFEC4899)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建创建整合包表单
  Widget _buildCreatePackForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 整合包名称
        const Text(
          '整合包名称',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: '输入整合包名称',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFFB3B3B3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFF0078D4)),
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          onChanged: (value) {
            setState(() {
              _packName = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // 整合包描述
        const Text(
          '整合包描述',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: '输入整合包描述',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFFB3B3B3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFF0078D4)),
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _packDescription = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // 游戏版本选择
        const Text(
          '游戏版本',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGameVersion,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFFB3B3B3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFF0078D4)),
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          items: _gameVersions.map((version) {
            return DropdownMenuItem(
              value: version,
              child: Text(version),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedGameVersion = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        
        // 加载器类型选择
        const Text(
          '加载器类型',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedLoaderType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFFB3B3B3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: Color(0xFF0078D4)),
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          items: _loaderTypes.map((loader) {
            return DropdownMenuItem(
              value: loader,
              child: Text(loader),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLoaderType = value;
              });
            }
          },
        ),
      ],
    );
  }
  
  // 构建格式标签 - Windows风格
  Widget _buildFormatChip(String extension, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              extension[1].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              extension,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
