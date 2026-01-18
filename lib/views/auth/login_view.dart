import 'package:flutter/material.dart';
import 'package:bamclauncher/services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 添加渐变背景，符合游戏风格
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF0F4FF), // 淡蓝色
              const Color(0xFFFDE6FF), // 淡粉色
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  
                  // 标题
                  const Text(
                    'BAMCLauncher',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '登录你的正版账号',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 错误信息
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(25, 239, 68, 68), // 0xFFEF4444 with 0.1 opacity
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444), width: 1),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontFamily: 'NotoSansSC',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Microsoft 登录按钮
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loginWithMicrosoft,
                    icon: Image.asset(
                      'assets/images/microsoft_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      '使用 Microsoft 账号登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansSC',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 离线模式按钮
                  OutlinedButton(
                    onPressed: _isLoading ? null : _loginOffline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                      foregroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '离线模式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansSC',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 说明文字
                  const Text(
                    '登录后，你的账号信息将被安全保存，用于启动游戏。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Microsoft 登录
  Future<void> _loginWithMicrosoft() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final result = await _authService.loginWithMicrosoft();
      
      if (mounted) {
        if (result['success']) {
          // 登录成功，返回上一页
          Navigator.pop(context, result);
        } else {
          setState(() {
            _errorMessage = '登录失败，请重试';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '登录失败: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // 离线模式
  void _loginOffline() {
    // 使用离线模式登录，生成随机UUID
    final offlineAuth = {
      'success': true,
      'accessToken': '0',
      'refreshToken': '0',
      'userId': 'offline-${DateTime.now().millisecondsSinceEpoch}',
      'username': 'Player${DateTime.now().millisecondsSinceEpoch % 1000}',
      'userType': 'offline',
    };
    
    Navigator.pop(context, offlineAuth);
  }
}