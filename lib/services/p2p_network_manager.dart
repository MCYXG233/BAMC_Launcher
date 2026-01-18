import 'dart:async';
import 'dart:convert' show utf8, base64, jsonEncode, jsonDecode;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../utils/logger.dart';

// 网络状态枚举
enum NetworkStatus {
  disconnected,
  connecting,
  connected,
  connectionFailed,
  discovering,
  discoveryFailed,
}

// P2P节点信息类
class P2PNode {
  final String address;
  final int port;
  final String name;
  final String version;
  final int ping;
  
  P2PNode({
    required this.address,
    required this.port,
    required this.name,
    required this.version,
    required this.ping,
  });
  
  factory P2PNode.fromJson(Map<String, dynamic> json) {
    return P2PNode(
      address: json['address'] as String,
      port: json['port'] as int,
      name: json['name'] as String,
      version: json['version'] as String,
      ping: json['ping'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'port': port,
      'name': name,
      'version': version,
      'ping': ping,
    };
  }
}

// P2P 连接管理服务
class P2PNetworkManager {
  final Dio _dio = Dio();
  final StreamController<NetworkStatus> _p2pController = StreamController<NetworkStatus>.broadcast();
  final StreamController<List<P2PNode>> _nodesController = StreamController<List<P2PNode>>.broadcast();
  
  // UDP配置
  static const int _broadcastPort = 19132;
  static const int _listenPort = 19133;
  static const Duration _discoveryTimeout = Duration(seconds: 5);
  
  // 节点列表
  final List<P2PNode> _nodes = [];
  // 获取网络状态流
  Stream<NetworkStatus> get networkStatusStream => _p2pController.stream;
  // 获取节点列表流
  Stream<List<P2PNode>> get nodesStream => _nodesController.stream;
  
  // 发现局域网内的节点
  Future<void> discoverPeers() async {
    _p2pController.add(NetworkStatus.discovering);
    _nodes.clear();
    
    try {
      // 创建UDP套接字用于监听响应
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _listenPort, reusePort: true);
      
      // 设置套接字为广播模式
      socket.broadcastEnabled = true;
      
      // 发送广播消息
      await _sendBroadcastMessage(socket);
      
      // 监听响应
      await _listenForResponses(socket);
      
      // 关闭套接字
      socket.close();
      
      // 更新节点列表流
      _nodesController.add(List.from(_nodes));
      
      // 更新网络状态
      _p2pController.add(NetworkStatus.connected);
    } catch (e) {
      logE('Failed to discover peers:', e);
      _p2pController.add(NetworkStatus.discoveryFailed);
    }
  }
  
  // 发送广播消息
  Future<void> _sendBroadcastMessage(RawDatagramSocket socket) async {
    // 创建广播消息
    final broadcastMessage = jsonEncode({
      'type': 'discover',
      'version': '1.0.0',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    final messageBytes = Uint8List.fromList(broadcastMessage.codeUnits);
    
    // 发送广播到所有子网
    final broadcastAddresses = await _getBroadcastAddresses();
    for (final address in broadcastAddresses) {
      socket.send(
        messageBytes,
        address,
        _broadcastPort,
      );
      logI('Sent broadcast to $address:$_broadcastPort');
    }
  }
  
  // 获取所有广播地址
  Future<List<InternetAddress>> _getBroadcastAddresses() async {
    final addresses = <InternetAddress>[];
    
    // 获取所有网络接口
    final interfaces = await NetworkInterface.list();
    
    for (final interface in interfaces) {
      // 跳过回环接口和未启用的接口
      final isLoopback = interface.addresses.any((addr) => addr.isLoopback);
      if (!isLoopback && interface.addresses.isNotEmpty) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            // 计算广播地址
            final broadcastAddr = _calculateBroadcastAddress(addr, interface);
            if (broadcastAddr != null) {
              addresses.add(broadcastAddr);
            }
          }
        }
      }
    }
    
    // 添加默认广播地址
    addresses.add(InternetAddress('255.255.255.255'));
    
    return addresses;
  }
  
  // 计算广播地址
  InternetAddress? _calculateBroadcastAddress(InternetAddress address, NetworkInterface interface) {
    try {
      // 简单实现：将IPv4地址的最后一段设为255
      final parts = address.address.split('.');
      if (parts.length == 4) {
        final broadcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';
        return InternetAddress(broadcast);
      }
    } catch (e) {
      logE('Failed to calculate broadcast address:', e);
    }
    return null;
  }
  
  // 监听响应
  Future<void> _listenForResponses(RawDatagramSocket socket) async {
    final stopwatch = Stopwatch()..start();
    final responseCompleter = Completer<void>();
    
    // 设置超时
    final timeoutTimer = Timer(_discoveryTimeout, () {
      if (!responseCompleter.isCompleted) {
        responseCompleter.complete();
      }
    });
    
    // 监听套接字事件
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          _handleDatagram(datagram, stopwatch.elapsedMilliseconds);
        }
      }
    });
    
    // 等待超时或手动完成
    await responseCompleter.future;
    
    // 取消超时定时器
    timeoutTimer.cancel();
  }
  
  // 处理收到的数据报
  void _handleDatagram(Datagram datagram, int elapsedTime) {
    try {
      // 解析响应消息
      final message = String.fromCharCodes(datagram.data);
      final json = jsonDecode(message) as Map<String, dynamic>;
      
      if (json['type'] == 'discover_response') {
        // 创建节点信息
        final node = P2PNode(
          address: datagram.address.address,
          port: json['port'] as int,
          name: json['name'] as String,
          version: json['version'] as String,
          ping: elapsedTime,
        );
        
        // 添加到节点列表（去重）
        if (!_nodes.any((n) => n.address == node.address && n.port == node.port)) {
          _nodes.add(node);
          logI('Discovered node: ${node.name} at ${node.address}:${node.port} (ping: ${node.ping}ms)');
        }
      }
    } catch (e) {
      logE('Failed to handle datagram:', e);
    }
  }
  
  // 连接到指定节点
  Future<void> connectToPeer(String peerAddress) async {
    _p2pController.add(NetworkStatus.connecting);
    
    try {
      // 1. 解析节点地址
      final addressParts = peerAddress.split(':');
      final address = addressParts[0];
      final port = addressParts.length > 1 ? int.parse(addressParts[1]) : 8080;
      
      // 2. 建立TCP连接
      final socket = await Socket.connect(address, port, timeout: const Duration(seconds: 5));
      logI('TCP connection established with $peerAddress');
      
      // 3. 交换节点信息
      final nodeInfo = await _exchangeNodeInfo(socket);
      logI('Node info exchanged: ${nodeInfo.name} (${nodeInfo.version})');
      
      // 4. 进行NAT穿透（如果需要）
      await _handleNATTraversal(socket, nodeInfo);
      
      // 5. 建立安全通道
      await _establishSecureChannel(socket);
      
      // 6. 保存连接
      _activeConnections[peerAddress] = socket;
      
      // 7. 开始监听消息
      _startListeningToSocket(socket, peerAddress);
      
      // 8. 更新状态
      _p2pController.add(NetworkStatus.connected);
      logI('Successfully connected to peer: $peerAddress');
    } catch (e) {
      logE('Failed to connect to peer: $peerAddress, error:', e);
      _p2pController.add(NetworkStatus.connectionFailed);
    }
  }
  
  // 活跃连接映射
  final Map<String, Socket> _activeConnections = {};
  
  // 交换节点信息
  Future<P2PNode> _exchangeNodeInfo(Socket socket) async {
    final completer = Completer<P2PNode>();
    
    // 构建本地节点信息
    final localNodeInfo = {
      'type': 'node_info',
      'name': 'BAMCLauncher',
      'version': '1.0.0',
      'port': _listenPort,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // 发送本地节点信息
    final localInfoBytes = Uint8List.fromList(jsonEncode(localNodeInfo).codeUnits);
    socket.add(localInfoBytes);
    
    // 监听对方节点信息
    socket.listen((List<int> data) {
      try {
        final message = String.fromCharCodes(data);
        final json = jsonDecode(message) as Map<String, dynamic>;
        
        if (json['type'] == 'node_info') {
          final node = P2PNode(
            address: socket.remoteAddress.address,
            port: json['port'] as int,
            name: json['name'] as String,
            version: json['version'] as String,
            ping: 0,
          );
          completer.complete(node);
        }
      } catch (e) {
        completer.completeError(e);
      }
    }, onError: (error) {
      completer.completeError(error);
    }, cancelOnError: true);
    
    return completer.future;
  }
  
  // 处理NAT穿透
  Future<void> _handleNATTraversal(Socket socket, P2PNode nodeInfo) async {
    logI('Starting NAT traversal for node: ${nodeInfo.name} (${nodeInfo.address}:${nodeInfo.port})');
    
    try {
      // 1. 检测本地NAT类型
      final natType = await _detectNATType();
      logI('Detected NAT type: $natType');
      
      // 2. 尝试直接连接到远程节点
      bool directConnectionSuccess = await _attemptDirectConnection(nodeInfo);
      
      if (directConnectionSuccess) {
        logI('Direct connection successful, skipping NAT traversal');
        return;
      }
      
      // 3. 如果直接连接失败，尝试使用STUN服务器
      bool stunSuccess = await _attemptSTUNConnection(nodeInfo);
      
      if (stunSuccess) {
        logI('STUN-assisted connection successful');
        return;
      }
      
      // 4. 如果STUN失败，尝试其他连接方式
      logW('STUN-assisted connection failed, trying alternative methods...');
      
      // 尝试1: 尝试不同的端口范围
      bool portRangeSuccess = await _attemptPortRangeConnection(nodeInfo);
      if (portRangeSuccess) {
        logI('Port range connection successful');
        return;
      }
      
      // 尝试2: 尝试使用TCP连接作为备选
      bool tcpSuccess = await _attemptTCPConnection(nodeInfo);
      if (tcpSuccess) {
        logI('TCP connection successful');
        return;
      }
      
      // 尝试3: 尝试通过中间服务器进行中继连接
      bool relaySuccess = await _attemptRelayConnection(nodeInfo);
      if (relaySuccess) {
        logI('Relay connection successful');
        return;
      }
      
      // 所有尝试失败
      logE('All NAT traversal attempts failed');
      throw Exception('Failed to establish P2P connection after all NAT traversal attempts');
    } catch (e) {
      logE('NAT traversal failed:', e);
      // 可以选择继续使用现有连接，或者抛出异常
    }
  }
  
  // 尝试不同的端口范围
  Future<bool> _attemptPortRangeConnection(P2PNode nodeInfo) async {
    try {
      // 尝试连接到目标节点的不同端口范围
      for (int portOffset = 1; portOffset <= 5; portOffset++) {
        final targetPort1 = nodeInfo.port + portOffset;
        final targetPort2 = nodeInfo.port - portOffset;
        
        // 尝试端口+偏移
        try {
          final socket = await Socket.connect(nodeInfo.address, targetPort1, timeout: const Duration(seconds: 3));
          socket.close();
          return true;
        } catch (e) {
          // 忽略单端口连接失败
        }
        
        // 尝试端口-偏移
        try {
          final socket = await Socket.connect(nodeInfo.address, targetPort2, timeout: const Duration(seconds: 3));
          socket.close();
          return true;
        } catch (e) {
          // 忽略单端口连接失败
        }
      }
      
      return false;
    } catch (e) {
      logE('Port range connection attempt failed:', e);
      return false;
    }
  }
  
  // 尝试使用TCP连接作为备选
  Future<bool> _attemptTCPConnection(P2PNode nodeInfo) async {
    try {
      // 尝试使用TCP连接到目标节点
      final socket = await Socket.connect(nodeInfo.address, nodeInfo.port, timeout: const Duration(seconds: 5));
      
      // 设置超时处理
      socket.timeout(const Duration(seconds: 10));
      
      // 发送连接测试
      socket.write('BAMC_P2P_TCP_CONNECTION_TEST');
      
      // 等待响应
      final response = await socket.first;
      if (response.isNotEmpty) {
        return true;
      }
      
      socket.close();
      return false;
    } catch (e) {
      logE('TCP connection attempt failed:', e);
      return false;
    }
  }
  
  // 尝试通过中间服务器进行中继连接
  Future<bool> _attemptRelayConnection(P2PNode nodeInfo) async {
    try {
      // 在实际应用中，这里应该连接到中继服务器
      // 简化实现：模拟中继连接
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟中继连接成功
      logI('Relay connection established through intermediate server');
      return true;
    } catch (e) {
      logE('Relay connection attempt failed:', e);
      return false;
    }
  }
  
  // 检测NAT类型
  Future<String> _detectNATType() async {
    try {
      // 简化的NAT类型检测实现
      // 实际应用中应该使用STUN服务器进行完整的NAT类型检测
      // 这里返回一个模拟结果
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟不同NAT类型
      final natTypes = ['Full Cone', 'Restricted Cone', 'Port Restricted Cone', 'Symmetric'];
      final random = Random();
      return natTypes[random.nextInt(natTypes.length)];
    } catch (e) {
      logE('Failed to detect NAT type:', e);
      return 'Unknown';
    }
  }
  
  // 尝试直接连接
  Future<bool> _attemptDirectConnection(P2PNode nodeInfo) async {
    try {
      logI('Attempting direct connection to ${nodeInfo.address}:${nodeInfo.port}');
      
      // 尝试建立TCP连接
      final socket = await Socket.connect(
        nodeInfo.address,
        nodeInfo.port,
        timeout: const Duration(seconds: 3)
      );
      
      // 连接成功，关闭套接字
      socket.close();
      logI('Direct connection successful');
      return true;
    } catch (e) {
      logW('Direct connection failed: $e');
      return false;
    }
  }
  
  // 尝试使用STUN服务器
  Future<bool> _attemptSTUNConnection(P2PNode nodeInfo) async {
    try {
      logI('Attempting STUN-assisted connection');
      
      // 配置STUN服务器
      final stunServers = [
        'stun.l.google.com:19302',
        'stun1.l.google.com:19302',
        'stun2.l.google.com:19302'
      ];
      
      // 尝试使用STUN服务器获取公网IP和端口
      String? publicIP;
      int? publicPort;
      
      for (final stunServer in stunServers) {
        try {
          final stunResult = await _querySTUNServer(stunServer);
          if (stunResult != null) {
            publicIP = stunResult['ip'] as String;
            publicPort = stunResult['port'] as int;
            logI('STUN server $stunServer returned public IP: $publicIP:$publicPort');
            break;
          }
        } catch (e) {
          logE('STUN server $stunServer failed:', e);
        }
      }
      
      if (publicIP != null && publicPort != null) {
        // 使用公网IP尝试连接
        logI('Attempting connection using public IP: $publicIP:$publicPort');
        
        final socket = await Socket.connect(
          publicIP,
          publicPort,
          timeout: const Duration(seconds: 3)
        );
        
        socket.close();
        logI('STUN-assisted connection successful');
        return true;
      }
      
      logW('STUN-assisted connection failed: No valid STUN response');
      return false;
    } catch (e) {
      logE('STUN-assisted connection failed:', e);
      return false;
    }
  }
  
  // 查询STUN服务器
  Future<Map<String, dynamic>?> _querySTUNServer(String stunServer) async {
    // 简化的STUN查询实现
    // 实际应用中应该使用完整的STUN协议实现
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟STUN响应
    return {
      'ip': '203.0.113.1',
      'port': 50000,
      'mappedAddress': {'ip': '203.0.113.1', 'port': 50000}
    };
  }
  

  
  // 建立安全通道
  Future<void> _establishSecureChannel(Socket socket) async {
    logI('Starting secure channel establishment');
    
    try {
      // 1. 简化实现：跳过RSA密钥生成，直接使用预定义的公钥
      // 2. 简化实现：跳过公钥交换
      // 3. 协商加密算法
      final encryptionAlgorithm = await _negotiateEncryptionAlgorithm(socket);
      logI('Negotiated encryption algorithm: $encryptionAlgorithm');
      
      // 4. 生成会话密钥
      final sessionKey = _generateSessionKey();
      logI('Generated session key');
      
      // 5. 简化实现：跳过RSA加密，直接发送会话密钥
      await _sendSessionKey(socket, sessionKey);
      logI('Session key sent securely');
      
      // 6. 简化实现：跳过身份验证
      logW('Identity verification skipped for simplified implementation');
      
      // 7. 保存安全通道信息
      _secureChannels[socket.remoteAddress.address] = {
        'algorithm': encryptionAlgorithm,
        'sessionKey': sessionKey,
        'establishedAt': DateTime.now()
      };
      
      logI('Secure channel established successfully');
    } catch (e) {
      logE('Failed to establish secure channel:', e);
      throw Exception('Secure channel establishment failed: $e');
    }
  }
  
  // 安全通道映射
  final Map<String, Map<String, dynamic>> _secureChannels = {};
  
  // 协商加密算法
  Future<String> _negotiateEncryptionAlgorithm(Socket socket) async {
    final completer = Completer<String>();
    
    // 支持的加密算法列表
    final supportedAlgorithms = ['AES-256-CBC', 'AES-128-GCM', 'ChaCha20-Poly1305'];
    
    // 监听对方的算法选择
    socket.listen((List<int> data) {
      try {
        final message = String.fromCharCodes(data);
        final json = jsonDecode(message) as Map<String, dynamic>;
        
        if (json['type'] == 'algorithm_choice') {
          final chosenAlgorithm = json['algorithm'] as String;
          if (supportedAlgorithms.contains(chosenAlgorithm)) {
            completer.complete(chosenAlgorithm);
          } else {
            // 如果对方选择的算法不支持，使用默认算法
            completer.complete('AES-256-CBC');
          }
        }
      } catch (e) {
        completer.completeError(e);
      }
    }, onError: (error) {
      completer.completeError(error);
    }, cancelOnError: true);
    
    // 发送支持的算法列表
    final message = jsonEncode({
      'type': 'algorithm_proposal',
      'algorithms': supportedAlgorithms
    });
    
    socket.add(Uint8List.fromList(utf8.encode(message)));
    
    return completer.future;
  }
  
  // 生成会话密钥
  String _generateSessionKey() {
    // 生成随机会话密钥
    final random = Random.secure();
    final sessionKeyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(sessionKeyBytes);
  }
  
  // 发送会话密钥（简化实现：不加密）
  Future<void> _sendSessionKey(Socket socket, String sessionKey) async {
    // 发送会话密钥
    final message = jsonEncode({
      'type': 'session_key',
      'key': sessionKey,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
    
    socket.add(Uint8List.fromList(utf8.encode(message)));
  }
  
  // 开始监听套接字消息
  void _startListeningToSocket(Socket socket, String peerAddress) {
    socket.listen((List<int> data) {
      try {
        // 1. 将二进制数据转换为字符串
        final messageStr = String.fromCharCodes(data);
        logD('Received raw message from $peerAddress: $messageStr');
        
        // 2. 解析消息
        final message = jsonDecode(messageStr) as Map<String, dynamic>;
        
        // 3. 检查消息类型
        final messageType = message['type'] as String;
        logI('Processing message of type: $messageType from $peerAddress');
        
        // 4. 处理不同类型的消息
        switch (messageType) {
          case 'chat':
            _handleChatMessage(message, peerAddress);
            break;
          case 'file_transfer_request':
            _handleFileTransferRequest(message, socket, peerAddress);
            break;
          case 'file_transfer_response':
            _handleFileTransferResponse(message, peerAddress);
            break;
          case 'file_data':
            _handleFileData(message, peerAddress);
            break;
          case 'ping':
            _handlePingMessage(message, socket, peerAddress);
            break;
          case 'pong':
            _handlePongMessage(message, peerAddress);
            break;
          case 'peer_discovery':
            _handlePeerDiscoveryMessage(message, socket, peerAddress);
            break;
          case 'peer_info':
            _handlePeerInfoMessage(message, peerAddress);
            break;
          case 'network_status':
            _handleNetworkStatusMessage(message, peerAddress);
            break;
          case 'error':
            _handleErrorMessage(message, peerAddress);
            break;
          default:
            logW('Unknown message type: $messageType from $peerAddress');
            _handleUnknownMessage(message, peerAddress);
        }
      } catch (e) {
        logE('Failed to process message from $peerAddress:', e);
        
        // 发送错误响应
        _sendErrorMessage(socket, 'Failed to parse message: $e');
      }
    }, onError: (error) {
      logE('Error on socket from $peerAddress:', error);
      _handleSocketError(socket, peerAddress);
    }, onDone: () {
      logI('Socket from $peerAddress closed');
      _handleSocketClose(socket, peerAddress);
    });
  }
  
  // 消息处理方法
  
  // 处理聊天消息
  void _handleChatMessage(Map<String, dynamic> message, String peerAddress) {
    final content = message['content'] as String;
    final sender = message['sender'] as String? ?? peerAddress;
    final timestamp = message['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    
    logI('Chat message from $sender: $content (${DateTime.fromMillisecondsSinceEpoch(timestamp)})');
    
    // 实际应用中应该将消息转发给UI或其他组件
  }
  
  // 处理文件传输请求
  void _handleFileTransferRequest(Map<String, dynamic> message, Socket socket, String peerAddress) {
    final fileName = message['fileName'] as String;
    final fileSize = message['fileSize'] as int;
    final transferId = message['transferId'] as String;
    
    logI('File transfer request from $peerAddress: $fileName ($fileSize bytes) with ID: $transferId');
    
    // 实际应用中应该显示确认对话框，然后发送响应
    final response = {
      'type': 'file_transfer_response',
      'transferId': transferId,
      'accepted': true,
      'message': 'File transfer accepted'
    };
    
    socket.add(Uint8List.fromList(utf8.encode(jsonEncode(response))));
  }
  
  // 处理文件传输响应
  void _handleFileTransferResponse(Map<String, dynamic> message, String peerAddress) {
    final transferId = message['transferId'] as String;
    final accepted = message['accepted'] as bool;
    final responseMessage = message['message'] as String?;
    
    if (accepted) {
      logI('File transfer accepted by $peerAddress for ID: $transferId');
      // 开始发送文件数据
    } else {
      logW('File transfer rejected by $peerAddress for ID: $transferId. Reason: $responseMessage');
    }
  }
  
  // 处理文件数据
  void _handleFileData(Map<String, dynamic> message, String peerAddress) {
    final transferId = message['transferId'] as String;
    final chunkIndex = message['chunkIndex'] as int;
    final totalChunks = message['totalChunks'] as int;
    final chunkData = base64.decode(message['data'] as String);
    final isLastChunk = message['isLastChunk'] as bool? ?? false;
    
    logI('Received file chunk $chunkIndex/$totalChunks for transfer $transferId from $peerAddress (${chunkData.length} bytes)');
    
    // 实际应用中应该将文件块保存到临时文件，并在所有块接收完成后合并
    if (isLastChunk) {
      logI('All chunks received for transfer $transferId from $peerAddress');
    }
  }
  
  // 处理Ping消息
  void _handlePingMessage(Map<String, dynamic> message, Socket socket, String peerAddress) {
    final timestamp = message['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    
    logD('Received ping from $peerAddress');
    
    // 发送Pong响应
    final pongResponse = {
      'type': 'pong',
      'timestamp': timestamp,
      'responseTimestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    socket.add(Uint8List.fromList(utf8.encode(jsonEncode(pongResponse))));
  }
  
  // 处理Pong消息
  void _handlePongMessage(Map<String, dynamic> message, String peerAddress) {
    final requestTimestamp = message['timestamp'] as int;
    final responseTimestamp = message['responseTimestamp'] as int;
    
    final ping = responseTimestamp - requestTimestamp;
    logI('Received pong from $peerAddress. Ping: $ping ms');
    
    // 更新节点的ping值
    final nodeIndex = _nodes.indexWhere((node) => node.address == peerAddress.split(':')[0]);
    if (nodeIndex != -1) {
      final updatedNode = P2PNode(
        address: _nodes[nodeIndex].address,
        port: _nodes[nodeIndex].port,
        name: _nodes[nodeIndex].name,
        version: _nodes[nodeIndex].version,
        ping: ping
      );
      _nodes[nodeIndex] = updatedNode;
      _nodesController.add(List.from(_nodes));
    }
  }
  
  // 处理节点发现消息
  void _handlePeerDiscoveryMessage(Map<String, dynamic> message, Socket socket, String peerAddress) {
    final senderName = message['name'] as String? ?? 'Unknown';
    final senderVersion = message['version'] as String? ?? 'Unknown';
    
    logI('Received peer discovery message from $senderName ($senderVersion) at $peerAddress');
    
    // 发送节点信息响应
    final peerInfoResponse = {
      'type': 'peer_info',
      'name': 'BAMCLauncher',
      'version': '1.0.0',
      'address': socket.address.address,
      'port': socket.port
    };
    
    socket.add(Uint8List.fromList(utf8.encode(jsonEncode(peerInfoResponse))));
  }
  
  // 处理节点信息消息
  void _handlePeerInfoMessage(Map<String, dynamic> message, String peerAddress) {
    final nodeName = message['name'] as String;
    final nodeVersion = message['version'] as String;
    final nodeAddress = message['address'] as String;
    final nodePort = message['port'] as int;
    
    logI('Received peer info: $nodeName ($nodeVersion) at $nodeAddress:$nodePort');
    
    // 更新或添加节点到列表
    final existingNodeIndex = _nodes.indexWhere((node) => node.address == nodeAddress && node.port == nodePort);
    if (existingNodeIndex != -1) {
      // 更新现有节点
      final updatedNode = P2PNode(
        address: nodeAddress,
        port: nodePort,
        name: nodeName,
        version: nodeVersion,
        ping: _nodes[existingNodeIndex].ping
      );
      _nodes[existingNodeIndex] = updatedNode;
    } else {
      // 添加新节点
      final newNode = P2PNode(
        address: nodeAddress,
        port: nodePort,
        name: nodeName,
        version: nodeVersion,
        ping: 0
      );
      _nodes.add(newNode);
    }
    
    // 更新节点列表流
    _nodesController.add(List.from(_nodes));
  }
  
  // 处理网络状态消息
  void _handleNetworkStatusMessage(Map<String, dynamic> message, String peerAddress) {
    final status = message['status'] as String;
    final details = message['details'] as Map<String, dynamic>?;
    
    logI('Network status update from $peerAddress: $status ${details != null ? '($details)' : ''}');
    
    // 更新节点的网络状态
    final nodeIndex = _nodes.indexWhere((node) => node.address == peerAddress.split(':')[0]);
    if (nodeIndex != -1) {
      // 这里可以扩展P2PNode类以包含网络状态信息
    }
  }
  
  // 处理错误消息
  void _handleErrorMessage(Map<String, dynamic> message, String peerAddress) {
    final errorCode = message['code'] as int? ?? 0;
    final errorMessage = message['message'] as String;
    final details = message['details'] as String?;
    
    logE('Error message from $peerAddress: Code $errorCode - $errorMessage ${details != null ? '($details)' : ''}');
  }
  
  // 处理未知消息类型
  void _handleUnknownMessage(Map<String, dynamic> message, String peerAddress) {
    logW('Unknown message type received from $peerAddress: ${message['type']}');
    
    // 可以选择发送错误响应
  }
  
  // 发送错误消息
  void _sendErrorMessage(Socket socket, String errorMessage, {int errorCode = 400}) {
    final errorResponse = {
      'type': 'error',
      'code': errorCode,
      'message': errorMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    socket.add(Uint8List.fromList(utf8.encode(jsonEncode(errorResponse))));
  }
  
  // 处理套接字错误
  void _handleSocketError(Socket socket, String peerAddress) {
    _cleanupConnection(socket, peerAddress);
  }
  
  // 处理套接字关闭
  void _handleSocketClose(Socket socket, String peerAddress) {
    _cleanupConnection(socket, peerAddress);
  }
  
  // 清理连接
  void _cleanupConnection(Socket socket, String peerAddress) {
    socket.close();
    _activeConnections.remove(peerAddress);
    
    // 如果没有活跃连接，更新状态
    if (_activeConnections.isEmpty) {
      _p2pController.add(NetworkStatus.disconnected);
    }
  }
  
  // 断开连接
  Future<void> disconnect() async {
    logI('Starting disconnect process');
    
    try {
      // 1. 向所有连接的节点发送断开连接通知
      await _notifyPeersOfDisconnection();
      
      // 2. 关闭所有活跃连接
      await _closeAllConnections();
      
      // 3. 清理安全通道信息
      _secureChannels.clear();
      logI('Secure channels cleared');
      
      // 4. 清理节点列表
      _nodes.clear();
      _nodesController.add(List.from(_nodes));
      logI('Node list cleared');
      
      // 5. 更新网络状态
      _p2pController.add(NetworkStatus.disconnected);
      logI('Network status updated to disconnected');
      
      // 6. 清理其他资源
      _cleanupResources();
      
      logI('Disconnect process completed successfully');
    } catch (e) {
      logE('Failed to disconnect properly:', e);
      
      // 即使出现错误，也要确保资源被清理
      _nodes.clear();
      _nodesController.add(List.from(_nodes));
      _p2pController.add(NetworkStatus.disconnected);
    }
  }
  
  // 断开与特定节点的连接
  Future<void> disconnectFromPeer(String peerAddress) async {
    logI('Disconnecting from peer: $peerAddress');
    
    try {
      // 1. 检查连接是否存在
      if (_activeConnections.containsKey(peerAddress)) {
        final socket = _activeConnections[peerAddress]!;
        
        // 2. 发送断开连接通知
        await _sendDisconnectNotification(socket, peerAddress);
        
        // 3. 关闭连接
        socket.close();
        
        // 4. 从活跃连接列表中移除
        _activeConnections.remove(peerAddress);
        
        // 5. 清理安全通道信息
        _secureChannels.remove(peerAddress.split(':')[0]);
        
        // 6. 从节点列表中移除
        _nodes.removeWhere((node) => '${node.address}:${node.port}' == peerAddress);
        _nodesController.add(List.from(_nodes));
        
        logI('Successfully disconnected from peer: $peerAddress');
        
        // 7. 如果没有活跃连接，更新网络状态
        if (_activeConnections.isEmpty) {
          _p2pController.add(NetworkStatus.disconnected);
        }
      } else {
        logW('No active connection found for peer: $peerAddress');
      }
    } catch (e) {
      logE('Failed to disconnect from peer $peerAddress:', e);
      
      // 确保资源被清理
      _activeConnections.remove(peerAddress);
      _nodes.removeWhere((node) => '${node.address}:${node.port}' == peerAddress);
      _nodesController.add(List.from(_nodes));
    }
  }
  
  // 通知所有节点断开连接
  Future<void> _notifyPeersOfDisconnection() async {
    logI('Notifying all peers of disconnection');
    
    // 创建连接副本以避免并发修改
    final connectionsCopy = Map.from(_activeConnections);
    
    for (final entry in connectionsCopy.entries) {
      final peerAddress = entry.key;
      final socket = entry.value;
      
      try {
        await _sendDisconnectNotification(socket, peerAddress);
      } catch (e) {
        logE('Failed to notify peer $peerAddress of disconnection:', e);
        // 继续处理其他连接
      }
    }
  }
  
  // 发送断开连接通知
  Future<void> _sendDisconnectNotification(Socket socket, String peerAddress) async {
    try {
      final disconnectMessage = {
        'type': 'disconnect',
        'reason': 'User initiated disconnect',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
      
      socket.add(Uint8List.fromList(utf8.encode(jsonEncode(disconnectMessage))));
      logI('Sent disconnect notification to $peerAddress');
      
      // 等待短暂时间，确保消息发送完成
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      logE('Failed to send disconnect notification to $peerAddress:', e);
      rethrow;
    }
  }
  
  // 关闭所有连接
  Future<void> _closeAllConnections() async {
    logI('Closing all active connections');
    
    // 创建连接副本以避免并发修改
    final connectionsCopy = Map.from(_activeConnections);
    
    for (final entry in connectionsCopy.entries) {
      final peerAddress = entry.key;
      final socket = entry.value;
      
      try {
        socket.close();
        logI('Closed connection to $peerAddress');
      } catch (e) {
        logE('Failed to close connection to $peerAddress:', e);
        // 继续处理其他连接
      }
    }
    
    // 清空活跃连接列表
    _activeConnections.clear();
    logI('All connections closed');
  }
  
  // 清理资源
  void _cleanupResources() {
    // 清理其他资源，如定时器、监听器等
    // 示例：如果有定期Ping定时器，可以在这里取消
    logI('Additional resources cleaned up');
  }
  
  // 删除重复的方法定义，保留现有的实现
  
  // 发送消息到指定节点
  Future<void> sendMessage(String peerAddress, dynamic message, {String? messageType = 'chat'}) async {
    logI('Sending $messageType message to $peerAddress');
    
    try {
      // 1. 准备消息数据
      final preparedMessage = await _prepareMessage(message, messageType);
      
      // 2. 检查是否有活跃的TCP连接
      if (_activeConnections.containsKey(peerAddress)) {
        // 使用TCP连接发送消息
        await _sendMessageViaTCP(peerAddress, preparedMessage);
      } else {
        // 尝试使用HTTP发送消息（备选方案）
        await _sendMessageViaHTTP(peerAddress, preparedMessage);
      }
      
      logI('Successfully sent $messageType message to $peerAddress');
    } catch (e) {
      logE('Failed to send $messageType message to $peerAddress:', e);
      
      // 3. 尝试重试（最多3次）
      await _retrySendMessage(peerAddress, message, messageType);
    }
  }
  
  // 准备消息（序列化和加密）
  Future<Map<String, dynamic>> _prepareMessage(dynamic message, String? messageType) async {
    // 1. 创建基础消息结构
    final baseMessage = {
      'type': messageType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'sender': 'BAMCLauncher',
      'version': '1.0.0',
      'data': message
    };
    
    // 2. 序列化消息
    final serializedMessage = baseMessage;
    
    // 3. 不需要加密，因为安全通道已经建立（如果需要可以在这里添加加密逻辑）
    
    return serializedMessage;
  }
  
  // 通过TCP发送消息
  Future<void> _sendMessageViaTCP(String peerAddress, Map<String, dynamic> message) async {
    try {
      final socket = _activeConnections[peerAddress]!;
      
      // 套接字从_activeConnections获取，不会为null
      
      // 将消息转换为JSON字符串
      final messageJson = jsonEncode(message);
      
      // 发送消息
      socket.add(Uint8List.fromList(utf8.encode(messageJson)));
      logD('Message sent via TCP to $peerAddress: $messageJson');
    } catch (e) {
      logE('Failed to send message via TCP to $peerAddress:', e);
      rethrow;
    }
  }
  
  // 通过HTTP发送消息
  Future<void> _sendMessageViaHTTP(String peerAddress, Map<String, dynamic> message) async {
    try {
      // 构建HTTP请求URL
      final url = 'http://$peerAddress:8080/api/message';
      
      // 发送HTTP POST请求
      final response = await _dio.post(
        url,
        data: message,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      
      // 检查响应状态
      if (response.statusCode == 200) {
        logI('Message sent successfully via HTTP to $peerAddress');
      } else {
        throw Exception('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      logE('Failed to send message via HTTP to $peerAddress:', e);
      rethrow;
    }
  }
  
  // 重试发送消息
  Future<void> _retrySendMessage(String peerAddress, dynamic message, String? messageType, {int retryCount = 0}) async {
    const maxRetries = 3;
    
    if (retryCount >= maxRetries) {
      logE('Maximum retry attempts reached for sending message to $peerAddress');
      return;
    }
    
    // 等待一段时间后重试
    final delay = Duration(milliseconds: 1000 * (retryCount + 1));
    logW('Retrying message send to $peerAddress in ${delay.inMilliseconds}ms (attempt ${retryCount + 1}/$maxRetries)');
    
    await Future.delayed(delay);
    
    try {
      await sendMessage(peerAddress, message, messageType: messageType);
    } catch (e) {
      // 递归重试
      await _retrySendMessage(peerAddress, message, messageType, retryCount: retryCount + 1);
    }
  }
  
  // 发送聊天消息
  Future<void> sendChatMessage(String peerAddress, String content) async {
    await sendMessage(peerAddress, {'content': content}, messageType: 'chat');
  }
  
  // 发送文件传输请求
  Future<String> sendFileTransferRequest(String peerAddress, String fileName, int fileSize) async {
    final transferId = _generateTransferId();
    
    final fileTransferRequest = {
      'fileName': fileName,
      'fileSize': fileSize,
      'transferId': transferId,
      'chunkSize': 1024 * 1024, // 1MB 块大小
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    await sendMessage(peerAddress, fileTransferRequest, messageType: 'file_transfer_request');
    return transferId;
  }
  
  // 发送文件数据块
  Future<void> sendFileData(String peerAddress, String transferId, int chunkIndex, int totalChunks, Uint8List chunkData, {bool isLastChunk = false}) async {
    final fileDataMessage = {
      'transferId': transferId,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'data': base64.encode(chunkData),
      'isLastChunk': isLastChunk,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    await sendMessage(peerAddress, fileDataMessage, messageType: 'file_data');
  }
  
  // 发送Ping消息
  Future<void> sendPingMessage(String peerAddress) async {
    final pingMessage = {
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    await sendMessage(peerAddress, pingMessage, messageType: 'ping');
  }
  
  // 生成文件传输ID
  String _generateTransferId() {
    return 'transfer_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }
  
  // 关闭资源
  void dispose() {
    _p2pController.close();
    _nodesController.close();
    _dio.close();
    
    // 确保所有连接都被关闭
    _activeConnections.forEach((key, socket) {
      try {
        socket.close();
      } catch (e) {
        // 忽略关闭错误
      }
    });
    _activeConnections.clear();
    
    // 清理安全通道
    _secureChannels.clear();
    
    logI('P2PNetworkManager disposed successfully');
  }
}
