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
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '登录你的正版账号',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              
              // 错误信息
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(25, 229, 57, 53), // 0xFFE53935 with 0.1 opacity
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE53935)),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 14,
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
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 离线模式按钮
              OutlinedButton(
                onPressed: _isLoading ? null : _loginOffline,
                child: const Text(
                  '离线模式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 说明文字
              const Text(
                '登录后，你的账号信息将被安全保存，用于启动游戏。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
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
      
      if (result['success']) {
        // 登录成功，返回上一页
        Navigator.pop(context, result);
      } else {
        setState(() {
          _errorMessage = '登录失败，请重试';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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