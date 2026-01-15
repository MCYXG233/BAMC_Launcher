import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'instance_manager.dart';
import 'p2p_network_manager.dart';
import 'settings_service.dart';
import 'version_manager.dart';

/// 服务定位器
/// 用于集中管理所有服务，实现解耦和统一接口
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  /// GetIt实例，用于服务注册和获取
  final GetIt _getIt = GetIt.instance;
  
  /// 初始化所有服务
  Future<void> initialize() async {
    // 注册单例服务
    _getIt.registerSingleton<SettingsService>(SettingsService());
    _getIt.registerSingleton<AuthService>(AuthService());
    _getIt.registerSingleton<InstanceManager>(InstanceManager());
    _getIt.registerSingleton<P2PNetworkManager>(P2PNetworkManager());
    _getIt.registerSingleton<VersionManager>(VersionManager());
    
    // 初始化必要的服务
    await get<SettingsService>().loadSettings();
  }
  
  /// 获取服务实例
  T get<T extends Object>() {
    return _getIt.get<T>();
  }
  
  /// 测试模式下重置服务定位器
  void reset() {
    _getIt.reset();
  }
}

/// 全局服务定位器实例
final serviceLocator = ServiceLocator();
