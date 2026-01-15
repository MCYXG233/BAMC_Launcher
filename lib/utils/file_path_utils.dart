import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import './logger.dart';

// 跨平台文件路径工具类
class FilePathUtils {
  // 获取应用数据目录
  static Future<String> getAppDataDirectory() async {
    Directory appDir;
    
    try {
      if (Platform.isAndroid) {
        // 检查存储权限
        final status = await Permission.storage.request();
        if (status.isDenied) {
          throw Exception('Storage permission denied');
        }
        appDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        appDir = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows) {
        final appDataPath = Platform.environment['APPDATA'] ?? '';
        if (appDataPath.isEmpty) {
          // 回退到文档目录
          appDir = await getApplicationDocumentsDirectory();
          appDir = Directory('${appDir.path}/BAMCLauncher');
        } else {
          appDir = Directory('$appDataPath/BAMCLauncher');
        }
      } else if (Platform.isMacOS) {
        final homePath = Platform.environment['HOME'] ?? '';
        if (homePath.isEmpty) {
          appDir = await getApplicationDocumentsDirectory();
          appDir = Directory('${appDir.path}/BAMCLauncher');
        } else {
          appDir = Directory('$homePath/Library/Application Support/BAMCLauncher');
        }
      } else if (Platform.isLinux) {
        final homePath = Platform.environment['HOME'] ?? '';
        if (homePath.isEmpty) {
          appDir = await getApplicationDocumentsDirectory();
          appDir = Directory('${appDir.path}/.config/BAMCLauncher');
        } else {
          appDir = Directory('$homePath/.config/BAMCLauncher');
        }
      } else {
        appDir = await getApplicationDocumentsDirectory();
        appDir = Directory('${appDir.path}/BAMCLauncher');
      }
      
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }
      
      return toCrossPlatformPath(appDir.path);
    } catch (e) {
      logE('Failed to get app data directory:', e);
      // 回退到当前工作目录
      final fallbackDir = Directory('.bamclauncher');
      if (!fallbackDir.existsSync()) {
        fallbackDir.createSync(recursive: true);
      }
      return toCrossPlatformPath(fallbackDir.path);
    }
  }
  
  // 获取实例目录
  static Future<String> getInstancesDirectory() async {
    final appDataDir = await getAppDataDirectory();
    final instancesDir = Directory('$appDataDir/instances');
    
    if (!instancesDir.existsSync()) {
      instancesDir.createSync(recursive: true);
    }
    
    return toCrossPlatformPath(instancesDir.path);
  }
  
  // 获取整合包目录
  static Future<String> getPacksDirectory() async {
    final appDataDir = await getAppDataDirectory();
    final packsDir = Directory('$appDataDir/packs');
    
    if (!packsDir.existsSync()) {
      packsDir.createSync(recursive: true);
    }
    
    return toCrossPlatformPath(packsDir.path);
  }
  
  // 获取Java目录
  static Future<String> getJavaDirectory() async {
    final appDataDir = await getAppDataDirectory();
    final javaDir = Directory('$appDataDir/java');
    
    if (!javaDir.existsSync()) {
      javaDir.createSync(recursive: true);
    }
    
    return toCrossPlatformPath(javaDir.path);
  }
  
  // 获取日志目录
  static Future<String> getLogsDirectory() async {
    final appDataDir = await getAppDataDirectory();
    final logsDir = Directory('$appDataDir/logs');
    
    if (!logsDir.existsSync()) {
      logsDir.createSync(recursive: true);
    }
    
    return toCrossPlatformPath(logsDir.path);
  }
  
  // 获取崩溃记录目录
  static Future<String> getCrashRecordsDirectory() async {
    final appDataDir = await getAppDataDirectory();
    final crashRecordsDir = Directory('$appDataDir/crash_records');
    
    if (!crashRecordsDir.existsSync()) {
      crashRecordsDir.createSync(recursive: true);
    }
    
    return toCrossPlatformPath(crashRecordsDir.path);
  }
  
  // 获取临时目录
  static Future<String> getTempDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final bamcTempDir = Directory('${tempDir.path}/BAMCLauncher');
      
      if (!bamcTempDir.existsSync()) {
        bamcTempDir.createSync(recursive: true);
      }
      
      return toCrossPlatformPath(bamcTempDir.path);
    } catch (e) {
      logE('Failed to get temp directory:', e);
      // 回退到系统临时目录
      final systemTemp = Directory.systemTemp;
      final bamcTempDir = Directory('${systemTemp.path}/BAMCLauncher');
      if (!bamcTempDir.existsSync()) {
        bamcTempDir.createSync(recursive: true);
      }
      return toCrossPlatformPath(bamcTempDir.path);
    }
  }
  
  // 转换为跨平台路径
  static String toCrossPlatformPath(String path) {
    if (Platform.isWindows) {
      return path.replaceAll('\\', '/');
    }
    return path;
  }
  
  // 转换为平台特定路径
  static String toPlatformPath(String path) {
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    }
    return path;
  }
  
  // 修复文件权限（针对Linux/macOS）
  static Future<void> fixFilePermissions(String filePath) async {
    if (Platform.isLinux || Platform.isMacOS) {
      final file = File(filePath);
      if (file.existsSync()) {
        try {
          await Process.run('chmod', ['+x', filePath]);
        } catch (e) {
          logE('Failed to fix permissions for $filePath:', e);
        }
      }
    }
  }
  
  // 修复目录权限（针对Linux/macOS）
  static Future<void> fixDirectoryPermissions(String dirPath) async {
    if (Platform.isLinux || Platform.isMacOS) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        try {
          await Process.run('chmod', ['-R', '755', dirPath]);
        } catch (e) {
          logE('Failed to fix directory permissions for $dirPath:', e);
        }
      }
    }
  }
  
  // 安全地删除文件
  static Future<void> safeDeleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      logE('Failed to delete file $filePath:', e);
    }
  }
  
  // 安全地删除目录
  static Future<void> safeDeleteDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      logE('Failed to delete directory $dirPath:', e);
    }
  }
  
  // 复制文件
  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      
      if (sourceFile.existsSync()) {
        // 确保目标目录存在
        final destinationDir = destinationFile.parent;
        if (!destinationDir.existsSync()) {
          destinationDir.createSync(recursive: true);
        }
        
        await sourceFile.copy(destinationPath);
        // 修复权限
        await fixFilePermissions(destinationPath);
      }
    } catch (e) {
      logE('Failed to copy file $sourcePath to $destinationPath:', e);
      rethrow;
    }
  }
  
  // 移动文件
  static Future<void> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      
      if (sourceFile.existsSync()) {
        // 确保目标目录存在
        final destinationDir = destinationFile.parent;
        if (!destinationDir.existsSync()) {
          destinationDir.createSync(recursive: true);
        }
        
        await sourceFile.rename(destinationPath);
        // 修复权限
        await fixFilePermissions(destinationPath);
      }
    } catch (e) {
      logE('Failed to move file $sourcePath to $destinationPath:', e);
      // 如果重命名失败（跨磁盘），尝试复制后删除
      await copyFile(sourcePath, destinationPath);
      await safeDeleteFile(sourcePath);
    }
  }
  
  // 读取文件内容（支持编码转换）
  static Future<String> readFileWithEncoding(String filePath, {Encoding encoding = utf8}) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }
      
      // 尝试用指定编码读取
      return await file.readAsString(encoding: encoding);
    } catch (e) {
      logE('Failed to read file $filePath with encoding $encoding:', e);
      
      // 尝试用utf8编码读取（针对中文文件）
      if (encoding != utf8) {
        try {
          final file = File(filePath);
          return await file.readAsString(encoding: utf8);
        } catch (utf8Error) {
          logE('Failed to read file $filePath with UTF-8 encoding:', utf8Error);
          // 最后尝试用latin1编码读取
          final file = File(filePath);
          return await file.readAsString(encoding: latin1);
        }
      }
      
      rethrow;
    }
  }
  
  // 写入文件内容
  static Future<void> writeFileWithEncoding(String filePath, String content, {Encoding encoding = utf8}) async {
    try {
      final file = File(filePath);
      
      // 确保目录存在
      final dir = file.parent;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      await file.writeAsString(content, encoding: encoding);
    } catch (e) {
      logE('Failed to write file $filePath:', e);
      rethrow;
    }
  }
  
  // 获取文件大小
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e) {
      logE('Failed to get file size for $filePath:', e);
      return 0;
    }
  }
  
  // 获取目录大小
  static Future<int> getDirectorySize(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        return 0;
      }
      
      int totalSize = 0;
      final List<FileSystemEntity> entities = await dir.list(recursive: true).toList();
      
      for (final entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      logE('Failed to get directory size for $dirPath:', e);
      return 0;
    }
  }
  
  // 格式化文件大小
  static String formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // 检查文件是否存在
  static bool fileExists(String filePath) {
    final file = File(filePath);
    return file.existsSync();
  }
  
  // 检查目录是否存在
  static bool directoryExists(String dirPath) {
    final dir = Directory(dirPath);
    return dir.existsSync();
  }
  
  // 获取文件名（不包含路径）
  static String getFileName(String filePath) {
    final file = File(filePath);
    return file.uri.pathSegments.last;
  }
  
  // 获取文件扩展名
  static String getFileExtension(String filePath) {
    final fileName = getFileName(filePath);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot > 0 && lastDot < fileName.length - 1) {
      return fileName.substring(lastDot + 1).toLowerCase();
    }
    return '';
  }
  
  // 获取文件名（不包含扩展名）
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = getFileName(filePath);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot > 0 && lastDot < fileName.length - 1) {
      return fileName.substring(0, lastDot);
    }
    return fileName;
  }
  
  // 创建多级目录
  static Future<void> createDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
      // 修复权限
      await fixDirectoryPermissions(dirPath);
    }
  }
}
