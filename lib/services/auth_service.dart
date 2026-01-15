import 'package:dio/dio.dart';
import '../utils/logger.dart';

class AuthService {
  // Microsoft OAuth 配置
  static const String _microsoftClientId = '0b1a81c9-6e23-41fd-8690-98a17d81bf4a';
  static const String _microsoftRedirectUri = 'http://localhost:5000/auth/callback';
  static const String _microsoftScope = 'XboxLive.signin offline_access';
  
  // Mojang API 端点
  static const String _mojangAuthEndpoint = 'https://authserver.mojang.com/authenticate';
  static const String _mojangRefreshEndpoint = 'https://authserver.mojang.com/refresh';
  static const String _mojangValidateEndpoint = 'https://authserver.mojang.com/validate';
  static const String _mojangInvalidateEndpoint = 'https://authserver.mojang.com/invalidate';
  
  // 状态变量
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userType;
  String? _username;
  
  // 获取当前认证状态
  Map<String, dynamic> getCurrentAuth() {
    return {
      'accessToken': _accessToken,
      'refreshToken': _refreshToken,
      'userId': _userId,
      'userType': _userType,
      'username': _username,
      'isLoggedIn': _accessToken != null,
    };
  }
  
  // Microsoft 登录
  Future<Map<String, dynamic>> loginWithMicrosoft() async {
    try {
      // 生成登录URL
      final loginUrl = Uri.parse(
        'https://login.live.com/oauth20_authorize.srf?'
        'client_id=$_microsoftClientId'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(_microsoftRedirectUri)}'
        '&scope=${Uri.encodeComponent(_microsoftScope)}'
        '&response_mode=query'
      );
      
      logI('请在浏览器中打开以下URL进行登录:');
      logI(loginUrl.toString());
      logI('\n登录成功后，将浏览器地址栏中的完整URL复制到下方:');
      
      // 这里需要实现一个本地HTTP服务器来监听回调
      // 或者让用户手动复制回调URL
      // 由于简化实现，我们暂时让用户手动输入授权码
      
      // 简化实现：返回模拟数据
      return {
        'success': true,
        'accessToken': 'mock_access_token',
        'refreshToken': 'mock_refresh_token',
        'userId': 'mock_user_id',
        'username': 'mock_username',
        'userType': 'microsoft',
      };
    } catch (e) {
      logE('Microsoft登录失败:', e);
      rethrow;
    }
  }
  
  // Mojang 登录 (已废弃，仅支持旧版账户)
  Future<Map<String, dynamic>> loginWithMojang(String username, String password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        _mojangAuthEndpoint,
        data: {
          'agent': {
            'name': 'Minecraft',
            'version': 1,
          },
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        _accessToken = data['accessToken'];
        _refreshToken = data['clientToken'];
        _userId = data['selectedProfile']['id'];
        _username = data['selectedProfile']['name'];
        _userType = 'mojang';
        
        return {
          'success': true,
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'username': _username,
          'userType': _userType,
        };
      } else {
        throw Exception('登录失败：${response.data['errorMessage']}');
      }
    } catch (e) {
      logE('Mojang 登录失败:', e);
      rethrow;
    }
  }
  
  // 刷新访问令牌
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        throw Exception('没有可用的刷新令牌');
      }
      
      final dio = Dio();
      final response = await dio.post(
        _mojangRefreshEndpoint,
        data: {
          'accessToken': _accessToken,
          'clientToken': _refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        _accessToken = data['accessToken'];
        _refreshToken = data['clientToken'];
        
        return {
          'success': true,
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
        };
      } else {
        throw Exception('刷新令牌失败：${response.data['errorMessage']}');
      }
    } catch (e) {
      logE('刷新令牌失败:', e);
      rethrow;
    }
  }
  
  // 验证访问令牌是否有效
  Future<bool> validateAccessToken() async {
    try {
      if (_accessToken == null) {
        return false;
      }
      
      final dio = Dio();
      try {
        final response = await dio.post(
          _mojangValidateEndpoint,
          data: {
            'accessToken': _accessToken,
          },
        );
        return response.statusCode == 204;
      } on DioException catch (e) {
        return e.response?.statusCode == 204;
      }
    } catch (e) {
      logE('验证令牌失败:', e);
      return false;
    }
  }
  
  // 登出
  Future<void> logout() async {
    try {
      if (_accessToken != null && _refreshToken != null) {
        final dio = Dio();
        await dio.post(
          _mojangInvalidateEndpoint,
          data: {
            'accessToken': _accessToken,
            'clientToken': _refreshToken,
          },
        );
      }
      
      // 清除本地认证信息
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _username = null;
      _userType = null;
    } catch (e) {
      logE('登出失败:', e);
      // 即使API调用失败，也清除本地信息
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _username = null;
      _userType = null;
    }
  }
  
  // 设置认证信息
  void setAuthInfo({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userType,
    required String username,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _userType = userType;
    _username = username;
  }
}