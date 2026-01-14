import 'package:flutter_test/flutter_test.dart';
import 'package:bamclauncher/services/instance_manager.dart';
import 'package:bamclauncher/utils/file_path_utils.dart';
import 'package:bamclauncher/services/version_manager.dart';
import 'package:bamclauncher/services/pack_format_detector.dart';

void main() {
  group('Core Services Test', () {
    test('FilePathUtils - Test directory creation', () async {
      // 测试获取应用数据目录
      final appDataDir = await FilePathUtils.getAppDataDirectory();
      expect(appDataDir, isNotNull);
      expect(appDataDir, isNotEmpty);
      
      // 测试获取实例目录
      final instancesDir = await FilePathUtils.getInstancesDirectory();
      expect(instancesDir, isNotNull);
      expect(instancesDir, isNotEmpty);
      
      // 测试获取整合包目录
      final packsDir = await FilePathUtils.getPacksDirectory();
      expect(packsDir, isNotNull);
      expect(packsDir, isNotEmpty);
      
      // 测试获取Java目录
      final javaDir = await FilePathUtils.getJavaDirectory();
      expect(javaDir, isNotNull);
      expect(javaDir, isNotEmpty);
      
      // 测试跨平台路径转换
      const windowsPath = 'C:\\Users\\User\\AppData\\Roaming\\BAMCLauncher';
      const unixPath = '/home/user/.config/BAMCLauncher';
      
      final convertedWindowsPath = FilePathUtils.toCrossPlatformPath(windowsPath);
      final convertedUnixPath = FilePathUtils.toCrossPlatformPath(unixPath);
      
      expect(convertedWindowsPath, contains('/'));
      expect(convertedUnixPath, contains('/'));
    });
    
    test('PackFormatDetector - Test format detection', () async {
      final detector = PackFormatDetector();
      
      // 测试.bamcpack格式检测
      final bamcpackFormat = await detector.detectFormat('test.bamcpack');
      expect(bamcpackFormat, equals(PackFormat.bamcpack));
      
      // 测试.pclpack格式检测
      final pclpackFormat = await detector.detectFormat('test.pclpack');
      expect(pclpackFormat, equals(PackFormat.pclpack));
      
      // 测试.mrpack格式检测
      final mrpackFormat = await detector.detectFormat('test.mrpack');
      expect(mrpackFormat, equals(PackFormat.mrpack));
      
      // 测试.zip格式检测
      final zipFormat = await detector.detectFormat('test.zip');
      expect(zipFormat, equals(PackFormat.mcbbs));
      
      // 测试.7z格式检测
      final sevenZipFormat = await detector.detectFormat('test.7z');
      expect(sevenZipFormat, equals(PackFormat.mcbbs));
      
      // 测试未知格式检测
      final unknownFormat = await detector.detectFormat('test.txt');
      expect(unknownFormat, equals(PackFormat.unknown));
    });
    
    test('VersionManager - Test version type detection', () async {
      final versionManager = VersionManager();
      
      // 测试版本类型检测
      final versionType = await versionManager.detectVersionType();
      expect(versionType, isNotNull);
      expect(versionType, isIn([VersionType.installer, VersionType.portable]));
      
      // 测试数据目录获取
      final dataDir = await versionManager.getDataDirectory();
      expect(dataDir, isNotNull);
      expect(dataDir, isNotEmpty);
      
      // 测试自动更新支持检测
      final isAutoUpdateSupported = await versionManager.isAutoUpdateSupported();
      expect(isAutoUpdateSupported, isNotNull);
      expect(isAutoUpdateSupported, isA<bool>());
    });
    
    test('InstanceManager - Test instance operations', () async {
      final instanceManager = InstanceManager();
      
      // 测试获取所有实例
      final instances = await instanceManager.getAllInstances();
      expect(instances, isNotNull);
      expect(instances, isA<List>());
      
      // 测试获取单个实例（不存在的实例）
      final nonExistentInstance = await instanceManager.getInstance('non-existent-id');
      expect(nonExistentInstance, isNull);
    });
  });
}
