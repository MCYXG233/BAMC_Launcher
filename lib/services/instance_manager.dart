import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:bamclauncher/services/pack_format_detector.dart';
import 'package:bamclauncher/services/bamc_pack_compressor.dart';
import 'package:bamclauncher/models/instance_model.dart';
import 'package:bamclauncher/utils/file_path_utils.dart';
import 'package:bamclauncher/utils/logger.dart';
import 'package:bamclauncher/services/pack_format_detector.dart';

// 实例管理服务
class InstanceManager {
  final PackFormatDetector _packFormatDetector = PackFormatDetector();
  final BamcPackCompressor _bamcPackCompressor = BamcPackCompressor();
  
  // 从整合包导入实例
  Future<InstanceModel> importFromPack(String packPath) async {
    try {
      // 检测整合包格式
      final format = await _packFormatDetector.detectFormat(packPath);
      logI('Detected pack format: $format');
      
      // 生成实例名称和目录
      final instanceName = _generateInstanceNameFromPack(packPath);
      final instancesDir = await FilePathUtils.getInstancesDirectory();
      final instanceDir = '$instancesDir/$instanceName';
      
      // 根据格式导入整合包
      switch (format) {
        case PackFormat.bamcpack:
          // 使用BamcPackCompressor解压.bamcpack格式
          await _bamcPackCompressor.decompress(packPath, instanceDir);
          break;
          
        case PackFormat.pclpack:
        case PackFormat.mrpack:
        case PackFormat.mcbbs:
          // 假设是zip格式，使用默认解压
          await _extractZipFile(packPath, instanceDir);
          break;
          
        default:
          throw Exception('Unsupported pack format: $format');
      }
      
      // 创建实例配置文件
      final instance = await _createInstanceFromPack(instanceDir, instanceName, format);
      
      logI('Pack imported successfully to: $instanceDir');
      return instance;
    } catch (e) {
      logE('Failed to import pack: $packPath, error:', e);
      rethrow;
    }
  }
  
  // 将实例导出为整合包
  Future<String> exportToPack(InstanceModel instance, String outputPath) async {
    try {
      // 创建整合包元数据文件
      final metadata = {
        'name': instance.name,
        'description': 'Exported from BAMCLauncher',
        'gameVersion': instance.minecraftVersion,
        'loaderType': instance.loaderType,
        'loaderVersion': instance.loaderVersion,
        'author': 'BAMCLauncher',
        'version': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final metadataFile = File('${instance.instanceDir}/metadata.json');
      await metadataFile.writeAsString(jsonEncode(metadata));
      
      // 使用BamcPackCompressor压缩为.bamcpack格式
      await _bamcPackCompressor.compress(instance.instanceDir, outputPath);
      
      logI('Instance exported to pack: $outputPath');
      return outputPath;
    } catch (e) {
      logE('Failed to export instance to pack: ${instance.name}, error:', e);
      rethrow;
    }
  }
  
  // 从整合包创建实例
  Future<InstanceModel> _createInstanceFromPack(String instanceDir, String instanceName, PackFormat format) async {
    try {
      // 检查是否存在metadata.json文件
      final metadataFile = File('$instanceDir/metadata.json');
      Map<String, dynamic> metadata = {};
      
      if (metadataFile.existsSync()) {
        // 读取metadata.json文件
        final metadataContent = await metadataFile.readAsString();
        metadata = jsonDecode(metadataContent);
      }
      
      // 检查是否存在instance.json文件
      final instanceJsonFile = File('$instanceDir/instance.json');
      if (instanceJsonFile.existsSync()) {
        // 读取已存在的instance.json文件
        final instanceContent = await instanceJsonFile.readAsString();
        final instanceJson = jsonDecode(instanceContent) as Map<String, dynamic>;
        return InstanceModel.fromJson(instanceJson);
      }
      
      // 创建新的实例配置
      final instance = InstanceModel(
        id: instanceName,
        name: metadata['name'] ?? instanceName,
        minecraftVersion: metadata['gameVersion'] ?? '1.20.4',
        loaderType: metadata['loaderType'] ?? 'vanilla',
        loaderVersion: metadata['loaderVersion'] ?? 'latest',
        javaPath: '',
        allocatedMemory: 2048,
        jvmArguments: [],
        gameArguments: [],
        instanceDir: instanceDir,
        iconPath: '',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: '',
        accessToken: '',
        userType: 'mojang',
      );
      
      // 写入instance.json文件
      final jsonString = jsonEncode(instance.toJson());
      await instanceJsonFile.writeAsString(jsonString);
      
      return instance;
    } catch (e) {
      logE('Failed to create instance from pack: $e');
      rethrow;
    }
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
      rethrow;
    }
  }
  // 获取所有实例
  Future<List<InstanceModel>> getAllInstances() async {
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final dir = Directory(instancesDir);
    
    if (!dir.existsSync()) {
      return [];
    }
    
    final instances = <InstanceModel>[];
    
    // 遍历实例目录
    final List<FileSystemEntity> entities = dir.listSync();
    for (final entity in entities) {
      if (entity is Directory) {
        final instanceJsonFile = File('${entity.path}/instance.json');
        if (instanceJsonFile.existsSync()) {
          try {
            final jsonString = await instanceJsonFile.readAsString();
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final instance = InstanceModel.fromJson(json);
            instances.add(instance);
          } catch (e) {
            logE('Failed to load instance: ${entity.path}, error:', e);
          }
        }
      }
    }
    
    return instances;
  }
  
  // 扫描Minecraft目录，自动识别实例
  Future<List<InstanceModel>> scanMinecraftDirectoryForInstances(String minecraftDir) async {
    final instances = <InstanceModel>[];
    
    // 检查Minecraft目录是否存在
    final dir = Directory(minecraftDir);
    if (!dir.existsSync()) {
      logW('Minecraft directory does not exist: $minecraftDir');
      return instances;
    }
    
    // 扫描versions目录，查找所有版本
    final versionsDir = Directory('$minecraftDir/versions');
    if (versionsDir.existsSync()) {
      final versionDirs = versionsDir.listSync().whereType<Directory>().toList();
      
      for (final versionDir in versionDirs) {
        try {
          // 检查是否存在版本json文件
          final versionName = versionDir.path.split(Platform.pathSeparator).last;
          final versionJsonFile = File('${versionDir.path}/$versionName.json');
          
          if (versionJsonFile.existsSync()) {
            logI('Found Minecraft version: $versionName');
            
            // 解析版本json，提取信息
            final jsonString = await versionJsonFile.readAsString();
            final versionJson = jsonDecode(jsonString) as Map<String, dynamic>;
            
            // 检测加载器类型
            final loaderInfo = _detectLoaderType(versionJson);
            
            // 创建实例模型
            final instance = InstanceModel(
              id: versionName,
              name: versionName,
              minecraftVersion: versionName,
              loaderType: loaderInfo['type'] as String,
              loaderVersion: loaderInfo['version'] as String,
              javaPath: '',
              allocatedMemory: 2048,
              jvmArguments: [],
              gameArguments: [],
              instanceDir: minecraftDir,
              iconPath: '',
              isActive: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            instances.add(instance);
            logI('Created instance for version: $versionName, loader: ${loaderInfo['type']} ${loaderInfo['version']}');
          }
        } catch (e) {
          logE('Failed to scan version: ${versionDir.path}, error:', e);
        }
      }
    }
    
    return instances;
  }
  
  // 检测加载器类型
  Map<String, dynamic> _detectLoaderType(Map<String, dynamic> versionJson) {
    final loaderInfo = {
      'type': 'vanilla',
      'version': '',
    };
    
    // 检查是否为Forge
    if (versionJson.containsKey('forgeVersion')) {
      loaderInfo['type'] = 'forge';
      loaderInfo['version'] = versionJson['forgeVersion'] as String;
    } 
    // 检查是否为Fabric
    else if (versionJson.containsKey('fabricLoader') || 
             versionJson.containsKey('fabric-loader') ||
             versionJson.containsKey('arguments') ||
             (versionJson.containsKey('mainClass') && 
              (versionJson['mainClass'] as String).contains('fabric'))) {
      loaderInfo['type'] = 'fabric';
      
      // 尝试提取Fabric版本
      if (versionJson.containsKey('fabricLoader')) {
        loaderInfo['version'] = versionJson['fabricLoader'] as String;
      } else if (versionJson.containsKey('fabric-loader')) {
        loaderInfo['version'] = versionJson['fabric-loader'] as String;
      } else {
        // 从mainClass或其他字段中提取版本信息
        final mainClass = versionJson['mainClass'] as String;
        if (mainClass.contains('fabric')) {
          // 尝试从id字段提取版本
          if (versionJson.containsKey('id')) {
            final id = versionJson['id'] as String;
            if (id.contains('fabric')) {
              final parts = id.split('-fabric-');
              if (parts.length > 1) {
                loaderInfo['version'] = parts[1];
              }
            }
          }
        }
      }
    }
    // 检查是否为Quilt
    else if ((versionJson.containsKey('mainClass') && 
             (versionJson['mainClass'] as String).contains('quilt')) ||
             versionJson.containsKey('quiltLoader')) {
      loaderInfo['type'] = 'quilt';
      
      // 尝试提取Quilt版本
      if (versionJson.containsKey('quiltLoader')) {
        loaderInfo['version'] = versionJson['quiltLoader'] as String;
      } else {
        // 从id字段提取版本
        if (versionJson.containsKey('id')) {
          final id = versionJson['id'] as String;
          if (id.contains('quilt')) {
            final parts = id.split('-quilt-');
            if (parts.length > 1) {
              loaderInfo['version'] = parts[1];
            }
          }
        }
      }
    }
    // 检查是否为OptiFine
    else if (versionJson.containsKey('id') &&
             (versionJson['id'] as String).contains('optifine')) {
      loaderInfo['type'] = 'optifine';
      
      // 尝试提取OptiFine版本
      final id = versionJson['id'] as String;
      final parts = id.split('-OptiFine_');
      if (parts.length > 1) {
        loaderInfo['version'] = parts[1];
      }
    }
    
    return loaderInfo;
  }
  
  // 导入外部实例到BAMCLauncher
  Future<InstanceModel> importExternalInstance(InstanceModel externalInstance) async {
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final newInstanceDir = Directory('$instancesDir/${externalInstance.id}');
    
    // 创建实例目录
    if (!newInstanceDir.existsSync()) {
      newInstanceDir.createSync(recursive: true);
    }
    
    // 复制必要文件
    await _copyInstanceFiles(externalInstance.instanceDir, newInstanceDir.path, externalInstance.minecraftVersion);
    
    // 保存实例配置
    final instanceJsonFile = File('${newInstanceDir.path}/instance.json');
    final updatedInstance = externalInstance.copyWith(
      instanceDir: newInstanceDir.path,
      updatedAt: DateTime.now(),
    );
    
    final jsonString = jsonEncode(updatedInstance.toJson());
    await instanceJsonFile.writeAsString(jsonString);
    
    logI('Successfully imported instance: ${externalInstance.name}');
    return updatedInstance;
  }
  
  // 复制实例文件
  Future<void> _copyInstanceFiles(String sourceDir, String targetDir, String version) async {
    // 复制versions目录
    final sourceVersionsDir = Directory('$sourceDir/versions/$version');
    final targetVersionsDir = Directory('$targetDir/versions/$version');
    
    if (sourceVersionsDir.existsSync()) {
      await _copyDirectory(sourceVersionsDir, targetVersionsDir);
    }
    
    // 复制libraries目录（如果存在）
    final sourceLibrariesDir = Directory('$sourceDir/libraries');
    final targetLibrariesDir = Directory('$targetDir/libraries');
    
    if (sourceLibrariesDir.existsSync()) {
      await _copyDirectory(sourceLibrariesDir, targetLibrariesDir);
    }
    
    // 复制assets目录（如果存在）
    final sourceAssetsDir = Directory('$sourceDir/assets');
    final targetAssetsDir = Directory('$targetDir/assets');
    
    if (sourceAssetsDir.existsSync()) {
      await _copyDirectory(sourceAssetsDir, targetAssetsDir);
    }
    
    // 复制config目录（如果存在）
    final sourceConfigDir = Directory('$sourceDir/config');
    final targetConfigDir = Directory('$targetDir/config');
    
    if (sourceConfigDir.existsSync()) {
      await _copyDirectory(sourceConfigDir, targetConfigDir);
    }
    
    // 复制mods目录（如果存在）
    final sourceModsDir = Directory('$sourceDir/mods');
    final targetModsDir = Directory('$targetDir/mods');
    
    if (sourceModsDir.existsSync()) {
      await _copyDirectory(sourceModsDir, targetModsDir);
    }
  }
  
  // 复制目录
  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }
    
    final entities = source.listSync();
    for (final entity in entities) {
      if (entity is File) {
        final targetFile = File('${target.path}/${entity.path.split(Platform.pathSeparator).last}');
        await entity.copy(targetFile.path);
      } else if (entity is Directory) {
        final targetSubDir = Directory('${target.path}/${entity.path.split(Platform.pathSeparator).last}');
        await _copyDirectory(entity, targetSubDir);
      }
    }
  }
  
  // 获取单个实例
  Future<InstanceModel?> getInstance(String id) async {
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final instanceDir = Directory('$instancesDir/$id');
    
    if (!instanceDir.existsSync()) {
      return null;
    }
    
    final instanceJsonFile = File('${instanceDir.path}/instance.json');
    if (!instanceJsonFile.existsSync()) {
      return null;
    }
    
    try {
      final jsonString = await instanceJsonFile.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return InstanceModel.fromJson(json);
    } catch (e) {
      logE('Failed to load instance: $id, error:', e);
      return null;
    }
  }
  
  // 创建实例
  Future<InstanceModel> createInstance(InstanceModel instance) async {
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final instanceDir = Directory('$instancesDir/${instance.id}');
    
    // 创建实例目录
    if (!instanceDir.existsSync()) {
      instanceDir.createSync(recursive: true);
    }
    
    // 保存实例配置
    final instanceJsonFile = File('${instanceDir.path}/instance.json');
    final jsonString = jsonEncode(instance.toJson());
    await instanceJsonFile.writeAsString(jsonString);
    
    // 创建必要的子目录
    final subDirs = ['mods', 'resourcepacks', 'saves', 'config', 'logs'];
    for (final subDir in subDirs) {
      final dir = Directory('${instanceDir.path}/$subDir');
      if (!dir.existsSync()) {
        dir.createSync();
      }
    }
    
    return instance;
  }
  
  // 更新实例
  Future<InstanceModel> updateInstance(InstanceModel instance) async {
    final updatedInstance = instance.copyWith(
      updatedAt: DateTime.now(),
    );
    
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final instanceJsonFile = File('$instancesDir/${instance.id}/instance.json');
    
    if (instanceJsonFile.existsSync()) {
      final jsonString = jsonEncode(updatedInstance.toJson());
      await instanceJsonFile.writeAsString(jsonString);
    }
    
    return updatedInstance;
  }
  
  // 删除实例
  Future<void> deleteInstance(String id) async {
    final instancesDir = await FilePathUtils.getInstancesDirectory();
    final instanceDir = Directory('$instancesDir/$id');
    
    if (instanceDir.existsSync()) {
      instanceDir.deleteSync(recursive: true);
    }
  }
  
  // 启动实例
  Future<void> launchInstance(InstanceModel instance) async {
    try {
      // 1. 验证Java环境
      final javaPath = await _verifyJavaEnvironment(instance.javaPath);
      logI('Using Java: $javaPath');
      
      // 2. 构建启动参数
      final launchArgs = await _buildLaunchArguments(instance, javaPath);
      logD('Launch arguments: $launchArgs');
      
      // 3. 启动Minecraft进程
      final process = await _startMinecraftProcess(launchArgs, instance.instanceDir);
      logI('Minecraft process started with PID: ${process.pid}');
      
      // 4. 监控进程状态
      _monitorProcess(process, instance);
      
      // 5. 更新实例状态
      await updateInstance(instance.copyWith(isActive: true));
      
      logI('Successfully launched instance: ${instance.name}');
    } catch (e) {
      logE('Failed to launch instance ${instance.name}:', e);
      rethrow;
    }
  }
  
  // 验证Java环境
  Future<String> _verifyJavaEnvironment(String javaPath) async {
    // 如果提供了Java路径，验证是否存在
    if (javaPath.isNotEmpty) {
      final javaFile = File(javaPath);
      if (javaFile.existsSync()) {
        // 验证Java版本
        await _verifyJavaVersion(javaPath);
        return javaPath;
      }
    }
    
    // 自动查找Java
    return await _findJavaAutomatically();
  }
  
  // 验证Java版本
  Future<void> _verifyJavaVersion(String javaPath) async {
    try {
      final result = await Process.run(
        javaPath,
        ['-version'],
        runInShell: true,
      );
      
      final output = result.stderr.toString().toLowerCase();
      logD('Java version output: $output');
      
      // 检查Java版本是否符合要求（至少Java 8）
      if (!output.contains('version "1.8') && 
          !output.contains('version "9') &&
          !output.contains('version "11') &&
          !output.contains('version "17')) {
        throw Exception('Unsupported Java version. Please use Java 8, 9, 11, or 17.');
      }
    } catch (e) {
      throw Exception('Failed to verify Java version: $e');
    }
  }
  
  // 自动查找Java
  Future<String> _findJavaAutomatically() async {
    final javaExecutable = Platform.isWindows ? 'java.exe' : 'java';
    
    try {
      // 检查系统PATH中的Java
      final result = await Process.run(
        'where.exe',
        [javaExecutable],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        final javaPath = result.stdout.toString().trim().split('\n').first;
        await _verifyJavaVersion(javaPath);
        return javaPath;
      }
    } catch (e) {
      logE('Failed to find Java in PATH:', e);
    }
    
    // 检查常见Java安装路径
    final commonPaths = Platform.isWindows ? [
      'C:\\Program Files\\Java\\jdk-17\\bin\\java.exe',
      'C:\\Program Files\\Java\\jdk-11\\bin\\java.exe',
      'C:\\Program Files\\Java\\jdk1.8.0_301\\bin\\java.exe',
      'C:\\Program Files (x86)\\Java\\jdk-17\\bin\\java.exe',
      'C:\\Program Files (x86)\\Java\\jdk-11\\bin\\java.exe',
      'C:\\Program Files (x86)\\Java\\jdk1.8.0_301\\bin\\java.exe',
    ] : [
      '/usr/bin/java',
      '/usr/local/bin/java',
      '/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java',
      '/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home/bin/java',
    ];
    
    for (final path in commonPaths) {
      final javaFile = File(path);
      if (javaFile.existsSync()) {
        try {
          await _verifyJavaVersion(path);
          return path;
        } catch (e) {
          logE('Java at $path is invalid:', e);
        }
      }
    }
    
    throw Exception('No valid Java environment found. Please install Java 8, 9, 11, or 17.');
  }
  
  // 构建启动参数
  Future<List<String>> _buildLaunchArguments(InstanceModel instance, String javaPath) async {
    final args = <String>[];
    
    // 添加JVM参数
    args.addAll(instance.jvmArguments);
    
    // 添加内存参数（如果没有指定）
    if (!instance.jvmArguments.any((arg) => arg.startsWith('-Xmx'))) {
      args.add('-Xmx${instance.allocatedMemory}M');
    }
    if (!instance.jvmArguments.any((arg) => arg.startsWith('-Xms'))) {
      args.add('-Xms2G');
    }
    
    // 添加游戏核心参数
    // 根据加载器类型构建不同的启动参数
    switch (instance.loaderType.toLowerCase()) {
      case 'forge':
        // Forge启动参数构建
        args.addAll(_buildForgeArguments(instance));
        break;
      case 'fabric':
        // Fabric启动参数构建
        args.addAll(_buildFabricArguments(instance));
        break;
      case 'quilt':
        // Quilt启动参数构建
        args.addAll(_buildQuiltArguments(instance));
        break;
      default:
        // 原版Minecraft启动参数构建
        args.addAll(_buildVanillaArguments(instance));
        break;
    }
    
    // 添加游戏参数
    args.addAll(instance.gameArguments);
    
    return args;
  }
  
  // 构建原版Minecraft启动参数
  List<String> _buildVanillaArguments(InstanceModel instance) {
    final args = <String>[];
    
    // 构建classpath
    final librariesDir = Directory('${instance.instanceDir}/libraries');
    final jars = <String>[];
    
    // 添加所有库文件
    if (librariesDir.existsSync()) {
      final libraryFiles = librariesDir.listSync(recursive: true)
          .where((file) => file is File && file.path.endsWith('.jar'))
          .map((file) => file.path)
          .toList();
      jars.addAll(libraryFiles);
    }
    
    // 添加Minecraft客户端jar
    final minecraftJar = '${instance.instanceDir}/versions/${instance.minecraftVersion}/${instance.minecraftVersion}.jar';
    jars.add(minecraftJar);
    
    // 添加classpath参数
    args.add('-cp');
    args.add(jars.join(Platform.isWindows ? ';' : ':'));
    args.add('net.minecraft.client.main.Main');
    
    // 添加游戏参数
    args.add('--version');
    args.add(instance.minecraftVersion);
    args.add('--gameDir');
    args.add(instance.instanceDir);
    args.add('--assetsDir');
    args.add('${instance.instanceDir}/assets');
    args.add('--assetIndex');
    args.add(instance.assetIndex ?? instance.minecraftVersion);
    args.add('--uuid');
    args.add(instance.userId);
    args.add('--accessToken');
    args.add(instance.accessToken);
    args.add('--userType');
    args.add(instance.userType);
    args.add('--versionType');
    args.add(instance.loaderType);
    
    // 添加额外的JVM参数
    if (instance.jvmArguments.isNotEmpty) {
      args.addAll(instance.jvmArguments);
    }
    
    // 添加额外的游戏参数
    if (instance.gameArguments.isNotEmpty) {
      args.addAll(instance.gameArguments);
    }
    
    return args;
  }
  
  // 构建Forge启动参数
  List<String> _buildForgeArguments(InstanceModel instance) {
    final args = <String>[];
    
    // 构建classpath
    final librariesDir = Directory('${instance.instanceDir}/libraries');
    final jars = <String>[];
    
    // 添加所有库文件
    if (librariesDir.existsSync()) {
      final libraryFiles = librariesDir.listSync(recursive: true)
          .where((file) => file is File && file.path.endsWith('.jar'))
          .map((file) => file.path)
          .toList();
      jars.addAll(libraryFiles);
    }
    
    // 添加Forge jar文件
    final forgeJar = '${instance.instanceDir}/versions/${instance.minecraftVersion}/forge-${instance.minecraftVersion}-${instance.loaderVersion}.jar';
    if (File(forgeJar).existsSync()) {
      jars.add(forgeJar);
    } else {
      // 尝试另一种Forge jar位置
      final alternativeForgeJar = '${instance.instanceDir}/forge-${instance.minecraftVersion}-${instance.loaderVersion}.jar';
      if (File(alternativeForgeJar).existsSync()) {
        jars.add(alternativeForgeJar);
      }
    }
    
    // 添加Minecraft客户端jar
    final minecraftJar = '${instance.instanceDir}/versions/${instance.minecraftVersion}/${instance.minecraftVersion}.jar';
    jars.add(minecraftJar);
    
    // 添加classpath参数
    args.add('-cp');
    args.add(jars.join(Platform.isWindows ? ';' : ':'));
    args.add('net.minecraftforge.fml.loading.FMLClientLaunchProvider');
    
    // 添加Forge特定参数
    args.add('--fml.ignoreInvalidMinecraftCertificates');
    args.add('--fml.ignorePatchDiscrepancies');
    
    // 添加游戏参数
    args.add('--version');
    args.add(instance.minecraftVersion);
    args.add('--gameDir');
    args.add(instance.instanceDir);
    args.add('--assetsDir');
    args.add('${instance.instanceDir}/assets');
    args.add('--assetIndex');
    args.add(instance.assetIndex ?? instance.minecraftVersion);
    args.add('--uuid');
    args.add(instance.userId);
    args.add('--accessToken');
    args.add(instance.accessToken);
    args.add('--userType');
    args.add(instance.userType);
    args.add('--versionType');
    args.add('forge');
    
    // 添加额外的JVM参数
    if (instance.jvmArguments.isNotEmpty) {
      args.addAll(instance.jvmArguments);
    }
    
    // 添加额外的游戏参数
    if (instance.gameArguments.isNotEmpty) {
      args.addAll(instance.gameArguments);
    }
    
    return args;
  }
  
  // 构建Fabric启动参数
  List<String> _buildFabricArguments(InstanceModel instance) {
    final args = <String>[];
    
    // 构建classpath
    final librariesDir = Directory('${instance.instanceDir}/libraries');
    final jars = <String>[];
    
    // 添加所有库文件
    if (librariesDir.existsSync()) {
      final libraryFiles = librariesDir.listSync(recursive: true)
          .where((file) => file is File && file.path.endsWith('.jar'))
          .map((file) => file.path)
          .toList();
      jars.addAll(libraryFiles);
    }
    
    // 添加Fabric loader jar
    final fabricLoaderJar = '${instance.instanceDir}/libraries/net/fabricmc/fabric-loader/${instance.loaderVersion}/fabric-loader-${instance.loaderVersion}.jar';
    if (File(fabricLoaderJar).existsSync()) {
      jars.add(fabricLoaderJar);
    } else {
      // 尝试另一种Fabric loader jar位置
      final alternativeFabricLoaderJar = '${instance.instanceDir}/fabric-loader-${instance.loaderVersion}-${instance.minecraftVersion}.jar';
      if (File(alternativeFabricLoaderJar).existsSync()) {
        jars.add(alternativeFabricLoaderJar);
      }
    }
    
    // 添加Minecraft客户端jar
    final minecraftJar = '${instance.instanceDir}/versions/${instance.minecraftVersion}/${instance.minecraftVersion}.jar';
    jars.add(minecraftJar);
    
    // 添加classpath参数
    args.add('-cp');
    args.add(jars.join(Platform.isWindows ? ';' : ':'));
    args.add('net.fabricmc.loader.launch.knot.KnotClient');
    
    // 添加游戏参数
    args.add('--version');
    args.add(instance.minecraftVersion);
    args.add('--gameDir');
    args.add(instance.instanceDir);
    args.add('--assetsDir');
    args.add('${instance.instanceDir}/assets');
    args.add('--assetIndex');
    args.add(instance.assetIndex ?? instance.minecraftVersion);
    args.add('--uuid');
    args.add(instance.userId);
    args.add('--accessToken');
    args.add(instance.accessToken);
    args.add('--userType');
    args.add(instance.userType);
    args.add('--versionType');
    args.add('fabric');
    
    // 添加额外的JVM参数
    if (instance.jvmArguments.isNotEmpty) {
      args.addAll(instance.jvmArguments);
    }
    
    // 添加额外的游戏参数
    if (instance.gameArguments.isNotEmpty) {
      args.addAll(instance.gameArguments);
    }
    
    return args;
  }
  
  // 构建Quilt启动参数
  List<String> _buildQuiltArguments(InstanceModel instance) {
    final args = <String>[];
    
    // 构建classpath
    final librariesDir = Directory('${instance.instanceDir}/libraries');
    final jars = <String>[];
    
    // 添加所有库文件
    if (librariesDir.existsSync()) {
      final libraryFiles = librariesDir.listSync(recursive: true)
          .where((file) => file is File && file.path.endsWith('.jar'))
          .map((file) => file.path)
          .toList();
      jars.addAll(libraryFiles);
    }
    
    // 添加Quilt loader jar
    final quiltLoaderJar = '${instance.instanceDir}/libraries/org/quiltmc/quilt-loader/${instance.loaderVersion}/quilt-loader-${instance.loaderVersion}.jar';
    if (File(quiltLoaderJar).existsSync()) {
      jars.add(quiltLoaderJar);
    } else {
      // 尝试另一种Quilt loader jar位置
      final alternativeQuiltLoaderJar = '${instance.instanceDir}/quilt-loader-${instance.loaderVersion}-${instance.minecraftVersion}.jar';
      if (File(alternativeQuiltLoaderJar).existsSync()) {
        jars.add(alternativeQuiltLoaderJar);
      }
    }
    
    // 添加Minecraft客户端jar
    final minecraftJar = '${instance.instanceDir}/versions/${instance.minecraftVersion}/${instance.minecraftVersion}.jar';
    jars.add(minecraftJar);
    
    // 添加classpath参数
    args.add('-cp');
    args.add(jars.join(Platform.isWindows ? ';' : ':'));
    args.add('org.quiltmc.loader.impl.launch.knot.KnotClient');
    
    // 添加游戏参数
    args.add('--version');
    args.add(instance.minecraftVersion);
    args.add('--gameDir');
    args.add(instance.instanceDir);
    args.add('--assetsDir');
    args.add('${instance.instanceDir}/assets');
    args.add('--assetIndex');
    args.add(instance.assetIndex ?? instance.minecraftVersion);
    args.add('--uuid');
    args.add(instance.userId);
    args.add('--accessToken');
    args.add(instance.accessToken);
    args.add('--userType');
    args.add(instance.userType);
    args.add('--versionType');
    args.add('quilt');
    
    // 添加额外的JVM参数
    if (instance.jvmArguments.isNotEmpty) {
      args.addAll(instance.jvmArguments);
    }
    
    // 添加额外的游戏参数
    if (instance.gameArguments.isNotEmpty) {
      args.addAll(instance.gameArguments);
    }
    
    return args;
  }
  
  // 启动Minecraft进程
  Future<Process> _startMinecraftProcess(List<String> launchArgs, String workingDir) async {
    try {
      // 构建完整的启动命令
      final javaPath = launchArgs.first;
      final args = launchArgs.skip(1).toList();
      
      // 启动进程
      final process = await Process.start(
        javaPath,
        args,
        workingDirectory: workingDir,
        runInShell: true,
      );
      
      return process;
    } catch (e) {
      throw Exception('Failed to start Minecraft process: $e');
    }
  }
  
  // 监控进程状态
  void _monitorProcess(Process process, InstanceModel instance) {
    // 监听进程退出
    process.exitCode.then((exitCode) async {
      logI('Minecraft process exited with code: $exitCode');
      
      // 更新实例状态
      await updateInstance(instance.copyWith(isActive: false));
      
      // 处理崩溃情况
      if (exitCode != 0) {
        await _handleProcessCrash(instance, exitCode);
      }
    });
    
    // 监听标准输出
    process.stdout.listen((List<int> data) {
      final output = String.fromCharCodes(data);
      logD('[Minecraft] $output');
      
      // 解析游戏日志，提取有用信息
      _parseGameLog(output, instance);
    });
    
    // 监听标准错误
    process.stderr.listen((List<int> data) {
      final error = String.fromCharCodes(data);
      logE('[Minecraft Error] $error');
      
      // 解析错误日志，检测崩溃原因
      _parseErrorLog(error, instance);
    });
  }
  
  // 解析错误日志
  void _parseErrorLog(String error, InstanceModel instance) {
    // 检测常见错误类型
    final errorTypes = [
      {
        'pattern': RegExp(r'OutOfMemoryError'),
        'type': '内存不足',
        'solution': '增加分配给Minecraft的内存',
      },
      {
        'pattern': RegExp(r'ClassNotFoundException'),
        'type': '类未找到',
        'solution': '检查mod兼容性或重新安装mod',
      },
      {
        'pattern': RegExp(r'NoClassDefFoundError'),
        'type': '类定义未找到',
        'solution': '检查mod依赖或更新mod',
      },
      {
        'pattern': RegExp(r'IllegalArgumentException'),
        'type': '非法参数',
        'solution': '检查启动参数或mod配置',
      },
      {
        'pattern': RegExp(r'NullPointerException'),
        'type': '空指针异常',
        'solution': '检查mod兼容性或更新mod',
      },
      {
        'pattern': RegExp(r'IndexOutOfBoundsException'),
        'type': '索引越界',
        'solution': '检查mod兼容性或更新mod',
      },
      {
        'pattern': RegExp(r'FileNotFoundException'),
        'type': '文件未找到',
        'solution': '检查游戏文件完整性或mod配置',
      },
      {
        'pattern': RegExp(r'SocketException'),
        'type': '网络连接错误',
        'solution': '检查网络连接或服务器状态',
      },
    ];
    
    // 检测错误类型
    for (final errorType in errorTypes) {
      final regex = errorType['pattern'] as RegExp;
      if (regex.hasMatch(error)) {
        final errorInfo = {
          'time': DateTime.now().toIso8601String(),
          'type': errorType['type'],
          'message': error.trim(),
          'solution': errorType['solution'],
        };
        
        logE('Detected error: ${errorType['type']} - ${errorType['solution']}');
        
        // 更新实例的错误信息
        _updateInstanceError(instance, errorInfo);
        break;
      }
    }
  }
  
  // 更新实例错误信息
  void _updateInstanceError(InstanceModel instance, Map<String, dynamic> errorInfo) {
    // 这里可以添加更新实例错误信息的逻辑
    logD('Updating instance error info: $errorInfo');
  }
  
  // 处理进程崩溃
  Future<void> _handleProcessCrash(InstanceModel instance, int exitCode) async {
    logE('Instance ${instance.name} crashed with exit code: $exitCode');
    
    // 1. 收集崩溃日志
    // 2. 分析崩溃原因
    // 3. 提供修复建议
    // 4. 保存崩溃记录
    
    // 更新实例状态为崩溃
    await updateInstance(
      instance.copyWith(
        isCrashed: true,
        crashReason: 'Exit code: $exitCode',
        lastCrashTime: DateTime.now(),
      ),
    );
  }
  
  // 解析游戏日志，提取有用信息
  void _parseGameLog(String logOutput, InstanceModel instance) {
    // 分割日志行
    final lines = logOutput.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      // 解析玩家加入信息
      if (line.contains('joined the game')) {
        _handlePlayerJoin(line, instance);
      }
      
      // 解析玩家退出信息
      else if (line.contains('left the game')) {
        _handlePlayerLeave(line, instance);
      }
      
      // 解析服务器连接信息
      else if (line.contains('Connecting to') || line.contains('Connected to')) {
        _handleServerConnection(line, instance);
      }
      
      // 解析游戏加载完成信息
      else if (line.contains('Ready') || line.contains('Game loaded')) {
        _handleGameReady(line, instance);
      }
      
      // 解析游戏崩溃信息
      else if (line.contains('Exception') || line.contains('Error') || line.contains('Crash')) {
        _handleGameError(line, instance);
      }
      
      // 解析资源加载信息
      else if (line.contains('Loading') || line.contains('Loaded')) {
        _handleResourceLoading(line, instance);
      }
    }
  }
  
  // 处理玩家加入游戏事件
  void _handlePlayerJoin(String logLine, InstanceModel instance) {
    // 提取玩家名称
    final playerName = logLine.split('joined the game')[0].trim();
    logI('Player $playerName joined the game in instance ${instance.name}');
    
    // 更新实例的在线玩家列表
    final updatedPlayers = List<String>.from(instance.onlinePlayers);
    if (!updatedPlayers.contains(playerName)) {
      updatedPlayers.add(playerName);
    }
    
    updateInstance(
      instance.copyWith(onlinePlayers: updatedPlayers),
    );
  }
  
  // 处理玩家离开游戏事件
  void _handlePlayerLeave(String logLine, InstanceModel instance) {
    // 提取玩家名称
    final playerName = logLine.split('left the game')[0].trim();
    logI('Player $playerName left the game in instance ${instance.name}');
    
    // 更新实例的在线玩家列表
    final updatedPlayers = List<String>.from(instance.onlinePlayers);
    updatedPlayers.remove(playerName);
    
    updateInstance(
      instance.copyWith(onlinePlayers: updatedPlayers),
    );
  }
  
  // 处理服务器连接事件
  void _handleServerConnection(String logLine, InstanceModel instance) {
    logD('Server connection: $logLine in instance ${instance.name}');
    
    // 更新实例连接状态
    String serverAddress = instance.serverAddress;
    
    // 提取服务器地址
    if (logLine.contains('Connecting to')) {
      final match = RegExp(r'Connecting to (.+?),').firstMatch(logLine);
      if (match != null) {
        serverAddress = match.group(1) ?? '';
      }
    }
    
    updateInstance(
      instance.copyWith(
        serverAddress: serverAddress,
        isConnectedToServer: true,
      ),
    );
  }
  
  // 处理游戏准备就绪事件
  void _handleGameReady(String logLine, InstanceModel instance) {
    logI('Game ready: $logLine in instance ${instance.name}');
    
    // 更新实例状态为就绪
    updateInstance(
      instance.copyWith(
        isGameReady: true,
        lastReadyTime: DateTime.now(),
      ),
    );
  }
  
  // 处理游戏错误事件
  void _handleGameError(String logLine, InstanceModel instance) {
    logE('Game error: $logLine in instance ${instance.name}');
    
    // 更新实例的错误信息
    final updatedErrors = List<Map<String, dynamic>>.from(instance.gameErrors);
    updatedErrors.add({
      'time': DateTime.now().toIso8601String(),
      'message': logLine,
    });
    
    updateInstance(
      instance.copyWith(gameErrors: updatedErrors),
    );
  }
  
  // 处理资源加载事件
  void _handleResourceLoading(String logLine, InstanceModel instance) {
    logD('Resource loading: $logLine in instance ${instance.name}');
    
    // 更新资源加载进度
    // 简单实现：根据日志行数增加进度
    double progress = instance.resourceLoadingProgress;
    if (progress < 1.0) {
      progress += 0.05;
      if (progress > 1.0) progress = 1.0;
      
      updateInstance(
        instance.copyWith(resourceLoadingProgress: progress),
      );
    }
  }
}