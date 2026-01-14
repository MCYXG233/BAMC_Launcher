import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// 版本类型枚举
enum VersionType {
  installer, // 安装版
  portable, // 便携版
}

// 版本管理服务
class VersionManager {
  static const String _versionTypeKey = 'version_type';
  static const String _portableFlagFile = 'portable.flag';
  
  // 检测当前版本类型
  Future<VersionType> detectVersionType() async {
    // 1. 检查是否存在便携版标识文件
    final executableDir = Directory(Platform.resolvedExecutable).parent;
    final portableFlagFile = File('${executableDir.path}/$_portableFlagFile');
    
    if (portableFlagFile.existsSync()) {
      await _saveVersionType(VersionType.portable);
      return VersionType.portable;
    }
    
    // 2. 检查共享偏好设置
    final prefs = await SharedPreferences.getInstance();
    final versionTypeStr = prefs.getString(_versionTypeKey);
    
    if (versionTypeStr != null) {
      return VersionType.values.byName(versionTypeStr);
    }
    
    // 3. 默认视为安装版
    await _saveVersionType(VersionType.installer);
    return VersionType.installer;
  }
  
  // 保存版本类型到共享偏好设置
  Future<void> _saveVersionType(VersionType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_versionTypeKey, type.name);
  }
  
  // 获取数据存储目录
  Future<String> getDataDirectory() async {
    final versionType = await detectVersionType();
    
    if (versionType == VersionType.portable) {
      // 便携版：数据存储在程序目录下
      final executableDir = Directory(Platform.resolvedExecutable).parent;
      final dataDir = Directory('${executableDir.path}/data');
      
      if (!dataDir.existsSync()) {
        dataDir.createSync(recursive: true);
      }
      
      return dataDir.path;
    } else {
      // 安装版：数据存储在系统标准位置
      // 这里使用之前实现的FilePathUtils.getAppDataDirectory()
      // 为了避免循环依赖，直接返回默认路径
      Directory appDir;
      
      if (Platform.isAndroid) {
        appDir = Directory('/storage/emulated/0/Android/data/com.bamclauncher/files');
      } else if (Platform.isIOS) {
        appDir = Directory('${Platform.environment['HOME']}/Library/Application Support/BAMCLauncher');
      } else if (Platform.isWindows) {
        appDir = Directory('${Platform.environment['APPDATA']}/BAMCLauncher');
      } else if (Platform.isMacOS) {
        appDir = Directory('${Platform.environment['HOME']}/Library/Application Support/BAMCLauncher');
      } else if (Platform.isLinux) {
        appDir = Directory('${Platform.environment['HOME']}/.config/BAMCLauncher');
      } else {
        appDir = Directory.current;
      }
      
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }
      
      return appDir.path;
    }
  }
  
  // 创建便携版标识文件
  Future<void> createPortableFlag() async {
    final executableDir = Directory(Platform.resolvedExecutable).parent;
    final portableFlagFile = File('${executableDir.path}/$_portableFlagFile');
    
    if (!portableFlagFile.existsSync()) {
      portableFlagFile.createSync();
    }
    
    await _saveVersionType(VersionType.portable);
  }
  
  // 移除便携版标识文件
  Future<void> removePortableFlag() async {
    final executableDir = Directory(Platform.resolvedExecutable).parent;
    final portableFlagFile = File('${executableDir.path}/$_portableFlagFile');
    
    if (portableFlagFile.existsSync()) {
      portableFlagFile.deleteSync();
    }
    
    await _saveVersionType(VersionType.installer);
  }
  
  // 检查是否支持自动更新
  Future<bool> isAutoUpdateSupported() async {
    final versionType = await detectVersionType();
    
    // 便携版不支持后台静默更新
    return versionType == VersionType.installer;
  }
}
