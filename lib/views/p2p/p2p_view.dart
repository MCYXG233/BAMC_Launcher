import 'package:flutter/material.dart';
import 'package:bamclauncher/components/anime_button.dart';
import 'package:bamclauncher/components/anime_card.dart';

// P2P 联机页面
class P2PView extends StatefulWidget {
  const P2PView({super.key});

  @override
  State<P2PView> createState() => _P2PViewState();
}

class _P2PViewState extends State<P2PView> {
  // 模拟房间数据
  final List<Map<String, dynamic>> _rooms = [
    {
      'id': '1',
      'name': '测试房间',
      'host': 'Player1',
      'players': 2,
      'maxPlayers': 8,
      'version': '1.19.4',
    },
    {
      'id': '2',
      'name': '生存房间',
      'host': 'Player2',
      'players': 4,
      'maxPlayers': 10,
      'version': '1.20.1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P 联机'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 操作按钮区
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      print('创建房间');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Text('创建房间', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      print('加入房间');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0078D4),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Color(0xFF0078D4)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 18),
                        SizedBox(width: 6),
                        Text('加入房间', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 房间列表区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _rooms.isEmpty ? 
                // 空状态
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 80,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无可用房间',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '创建一个房间或等待其他玩家创建',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ) : 
                // 房间列表
                ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          leading: const Icon(
                            Icons.groups,
                            size: 28,
                            color: Color(0xFF0078D4),
                          ),
                          title: Text(
                            room['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '房主: ${room['host']} | 版本: ${room['version']} | 人数: ${room['players']}/${room['maxPlayers']}',
                            style: const TextStyle(
                              color: Color(0xFF6E6E6E),
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            print('加入房间: ${room['name']}');
                          },
                          trailing: SizedBox(
                            width: 80,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                print('加入房间: ${room['name']}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0078D4),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                              child: const Text('加入', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),
        ],
      ),
    );
  }
}
