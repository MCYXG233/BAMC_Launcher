import 'dart:convert';
import 'package:http/http.dart' as http;

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
      
      print('请在浏览器中打开以下URL进行登录:');
      print(loginUrl.toString());
      print('\n登录成功后，将浏览器地址栏中的完整URL复制到下方:');
      
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
      print('Microsoft登录失败: $e');
      rethrow;
    }
  }
  
  // Mojang 登录 (已废弃，仅支持旧版账户)
  Future<Map<String, dynamic>> loginWithMojang(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_mojangAuthEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'agent': {
            'name': 'Minecraft',
            'version': 1,
          },
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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
        throw Exception('登录失败：${jsonDecode(response.body)['errorMessage']}');
      }
    } catch (e) {
      print('Mojang 登录失败: $e');
      rethrow;
    }
  }
  
  // 刷新访问令牌
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        throw Exception('没有可用的刷新令牌');
      }
      
      final response = await http.post(
        Uri.parse(_mojangRefreshEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': _accessToken,
          'clientToken': _refreshToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _accessToken = data['accessToken'];
        _refreshToken = data['clientToken'];
        
        return {
          'success': true,
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
        };
      } else {
        throw Exception('刷新令牌失败：${jsonDecode(response.body)['errorMessage']}');
      }
    } catch (e) {
      print('刷新令牌失败: $e');
      rethrow;
    }
  }
  
  // 验证访问令牌是否有效
  Future<bool> validateAccessToken() async {
    try {
      if (_accessToken == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse(_mojangValidateEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': _accessToken,
        }),
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('验证令牌失败: $e');
      return false;
    }
  }
  
  // 登出
  Future<void> logout() async {
    try {
      if (_accessToken != null && _refreshToken != null) {
        await http.post(
          Uri.parse(_mojangInvalidateEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'accessToken': _accessToken,
            'clientToken': _refreshToken,
          }),
        );
      }
      
      // 清除本地认证信息
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _username = null;
      _userType = null;
    } catch (e) {
      print('登出失败: $e');
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