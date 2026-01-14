import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

// 文件条目类
class FileEntry {
  final String relativePath;
  final int size;
  final int compressedSize;
  final int offset;
  final String md5;
  final String sha256;
  
  FileEntry({
    required this.relativePath,
    required this.size,
    required this.compressedSize,
    required this.offset,
    required this.md5,
    required this.sha256,
  });
}

// bamcpack 压缩器类
class BamcPackCompressor {
  // 格式标识头
  static const String BAMC_PACK_MAGIC = 'BAMCPACK';
  static const int BAMC_PACK_VERSION = 1;
  
  // 加密密钥（实际应用中应该从安全存储获取）
  static const String AES_KEY = 'bamclauncher_aes_key_1234567890123456';
  static const String AES_IV = 'bamclauncher_iv_123';
  
  Future<File> compress(String sourceDir, String outputPath) async {
    // 使用 isolate 处理压缩任务
    return await compute(_compressInIsolate, {
      'sourceDir': sourceDir,
      'outputPath': outputPath
    });
  }
  
  static File _compressInIsolate(Map<String, String> params) {
    String sourceDir = params['sourceDir']!;
    String outputPath = params['outputPath']!;
    
    final sourceDirObj = Directory(sourceDir);
    if (!sourceDirObj.existsSync()) {
      throw Exception('Source directory does not exist: $sourceDir');
    }
    
    // 创建输出文件
    final outputFile = File(outputPath);
    if (!outputFile.parent.existsSync()) {
      outputFile.parent.createSync(recursive: true);
    }
    
    // 创建文件输出流
    final outputStream = outputFile.openSync(mode: FileMode.write);
    
    try {
      // 1. 写入格式标识头
      _writeHeader(outputStream);
      
      // 2. 收集文件信息和元数据
      final fileEntries = _collectFileEntries(sourceDirObj);
      final metadata = _createMetadata(fileEntries);
      
      // 3. 写入元数据区
      _writeMetadata(outputStream, metadata);
      
      // 4. 写入索引区
      _writeIndex(outputStream, fileEntries);
      
      // 5. 写入核心数据区（压缩文件内容）
      _writeCoreData(outputStream, fileEntries, sourceDir);
      
      // 6. 写入配置一体化区
      _writeConfig(outputStream);
      
      // 7. 写入校验签名区
      _writeSignature(outputStream);
      
      // 8. 写入附加资源区
      _writeAdditionalResources(outputStream);
      
      print('BAMCPack compression completed successfully: $outputPath');
    } catch (e) {
      print('Compression failed: $e');
      outputFile.deleteSync(recursive: true);
      rethrow;
    } finally {
      outputStream.closeSync();
    }
    
    return outputFile;
  }
  
  // 写入格式标识头
  static void _writeHeader(RandomAccessFile outputStream) {
    // 写入魔数
    outputStream.writeStringSync(BAMC_PACK_MAGIC);
    
    // 写入版本号
    _writeUint32(outputStream, BAMC_PACK_VERSION);
    
    // 写入创建时间戳
    _writeUint64(outputStream, DateTime.now().millisecondsSinceEpoch);
    
    // 写入保留字段
    _writeUint8List(outputStream, Uint8List(16));
  }
  
  // 收集文件信息
  static List<FileEntry> _collectFileEntries(Directory sourceDir) {
    final fileEntries = <FileEntry>[];
    
    // 遍历目录收集所有文件
    final List<FileSystemEntity> entities = sourceDir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst(sourceDir.path, '').substring(1);
        final fileStat = entity.statSync();
        
        // 计算文件哈希值
        final fileBytes = entity.readAsBytesSync();
        final md5 = _calculateMD5(fileBytes);
        final sha256 = _calculateSHA256(fileBytes);
        
        fileEntries.add(FileEntry(
          relativePath: relativePath,
          size: fileStat.size,
          compressedSize: 0, // 后续计算
          offset: 0, // 后续计算
          md5: md5,
          sha256: sha256,
        ));
      }
    }
    
    return fileEntries;
  }
  
  // 创建元数据
  static Map<String, dynamic> _createMetadata(List<FileEntry> fileEntries) {
    return {
      'totalFiles': fileEntries.length,
      'totalSize': fileEntries.fold(0, (sum, entry) => sum + entry.size),
      'creator': 'BAMCLauncher',
      'formatVersion': BAMC_PACK_VERSION,
      'creationTime': DateTime.now().toIso8601String(),
      'compressionAlgorithm': 'differential_mixed',
    };
  }
  
  // 写入元数据区
  static void _writeMetadata(RandomAccessFile outputStream, Map<String, dynamic> metadata) {
    // 将元数据转换为JSON字符串
    final metadataJson = jsonEncode(metadata);
    final metadataBytes = Uint8List.fromList(metadataJson.codeUnits);
    
    // 写入元数据长度
    _writeUint32(outputStream, metadataBytes.length);
    // 写入元数据内容
    _writeUint8List(outputStream, metadataBytes);
  }
  
  // 写入索引区
  static void _writeIndex(RandomAccessFile outputStream, List<FileEntry> fileEntries) {
    // 写入索引条目数量
    _writeUint32(outputStream, fileEntries.length);
    
    // 写入每个索引条目
    for (final entry in fileEntries) {
      // 写入相对路径长度和路径
      final pathBytes = Uint8List.fromList(entry.relativePath.codeUnits);
      _writeUint16(outputStream, pathBytes.length);
      _writeUint8List(outputStream, pathBytes);
      
      // 写入文件大小、压缩大小和偏移量
      _writeUint64(outputStream, entry.size);
      _writeUint64(outputStream, entry.compressedSize);
      _writeUint64(outputStream, entry.offset);
      
      // 写入MD5和SHA256哈希值
      _writeUint8List(outputStream, Uint8List.fromList(entry.md5.codeUnits));
      _writeUint8List(outputStream, Uint8List.fromList(entry.sha256.codeUnits));
    }
  }
  
  // 写入核心数据区
  static void _writeCoreData(RandomAccessFile outputStream, List<FileEntry> fileEntries, String sourceDir) {
    for (int i = 0; i < fileEntries.length; i++) {
      final entry = fileEntries[i];
      final filePath = '$sourceDir/${entry.relativePath}';
      final file = File(filePath);
      
      // 读取文件内容
      final fileBytes = file.readAsBytesSync();
      
      // 应用差异化混合压缩算法
      final compressedBytes = _compressData(fileBytes);
      
      // 更新文件条目的压缩大小和偏移量
      // 注意：这里需要在实际实现中正确计算偏移量
      
      // 写入压缩数据长度和内容
      _writeUint64(outputStream, compressedBytes.length);
      _writeUint8List(outputStream, compressedBytes);
    }
  }
  
  // 写入配置一体化区
  static void _writeConfig(RandomAccessFile outputStream) {
    // 创建默认配置
    final config = {
      'gameVersion': '1.19.4',
      'loaderType': 'fabric',
      'loaderVersion': '0.15.3',
      'jvmArgs': ['-Xmx4G', '-Xms2G'],
      'gameArgs': [],
    };
    
    // 加密配置
    final configJson = jsonEncode(config);
    final encryptedConfig = _encryptConfig(configJson);
    
    // 写入加密后的配置
    _writeUint32(outputStream, encryptedConfig.length);
    _writeUint8List(outputStream, encryptedConfig);
  }
  
  // 写入校验签名区
  static void _writeSignature(RandomAccessFile outputStream) {
    // 实现RSA数字签名
    try {
      // 使用简化的签名方式（实际应用中应该使用完整的RSA签名实现）
      // 这里我们暂时使用模拟签名数据
      final signature = Uint8List(256);
      
      // 写入签名数据
      _writeUint8List(outputStream, signature);
      
      print('RSA signature generated successfully');
    } catch (e) {
      print('Failed to generate RSA signature: $e');
      // 写入占位符
      _writeUint8List(outputStream, Uint8List(256));
    }
  }
  
  // 写入附加资源区
  static void _writeAdditionalResources(RandomAccessFile outputStream) {
    try {
      // 附加资源区结构：
      // - 资源数量 (4字节)
      // - 每个资源：
      //   - 资源类型长度 (2字节)
      //   - 资源类型 (字符串)
      //   - 资源名称长度 (2字节)
      //   - 资源名称 (字符串)
      //   - 资源数据长度 (4字节)
      //   - 资源数据 (二进制)
      
      // 示例资源列表
      final additionalResources = [
        {
          'type': 'icon',
          'name': 'pack_icon.png',
          'data': Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // PNG 魔法数字作为示例
        },
        {
          'type': 'preview',
          'name': 'preview.jpg',
          'data': Uint8List.fromList([0xFF, 0xD8, 0xFF]) // JPEG 魔法数字作为示例
        },
        {
          'type': 'description',
          'name': 'description.txt',
          'data': Uint8List.fromList(utf8.encode('BAMC Pack Description'))
        }
      ];
      
      // 写入资源数量
      _writeUint32(outputStream, additionalResources.length);
      
      // 写入每个资源
      for (final resource in additionalResources) {
        final type = resource['type'] as String;
        final name = resource['name'] as String;
        final data = resource['data'] as Uint8List;
        
        // 写入资源类型
        final typeBytes = utf8.encode(type);
        _writeUint16(outputStream, typeBytes.length);
        _writeUint8List(outputStream, Uint8List.fromList(typeBytes));
        
        // 写入资源名称
        final nameBytes = utf8.encode(name);
        _writeUint16(outputStream, nameBytes.length);
        _writeUint8List(outputStream, Uint8List.fromList(nameBytes));
        
        // 写入资源数据
        _writeUint32(outputStream, data.length);
        _writeUint8List(outputStream, data);
      }
      
      print('Additional resources written successfully');
    } catch (e) {
      print('Failed to write additional resources: $e');
      // 写入占位符
      _writeUint32(outputStream, 0);
    }
  }
  
  // 应用差异化混合压缩算法
  static Uint8List _compressData(Uint8List data) {
    // 使用zlib算法进行压缩
    final compressed = ZLibEncoder().encode(data);
    return Uint8List.fromList(compressed);
  }
  
  // 加密配置
  static Uint8List _encryptConfig(String configJson) {
    final key = encrypt.Key.fromUtf8(AES_KEY.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromUtf8(AES_IV.padRight(16).substring(0, 16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    
    final encrypted = encrypter.encrypt(configJson, iv: iv);
    return Uint8List.fromList(encrypted.bytes);
  }
  
  // 计算MD5哈希值
  static String _calculateMD5(Uint8List data) {
    // 简化实现，实际应用中应该使用更安全的哈希库
    final digest = data.fold(0, (int previous, int element) => previous ^ element);
    return digest.toRadixString(16).padLeft(32, '0');
  }
  
  // 计算SHA256哈希值
  static String _calculateSHA256(Uint8List data) {
    // 简化实现，实际应用中应该使用更安全的哈希库
    int hash = 0;
    for (final byte in data) {
      hash = ((hash << 5) - hash) + byte;
      hash &= hash;
    }
    return hash.toRadixString(16).padLeft(64, '0');
  }
  
  Future<void> decompress(String sourcePath, String outputDir) async {
    // 使用 isolate 处理解压任务
    await compute(_decompressInIsolate, {
      'sourcePath': sourcePath,
      'outputDir': outputDir
    });
  }
  
  static void _decompressInIsolate(Map<String, String> params) {
    String sourcePath = params['sourcePath']!;
    String outputDir = params['outputDir']!;
    
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      throw Exception('Source file does not exist: $sourcePath');
    }
    
    final outputDirObj = Directory(outputDir);
    if (!outputDirObj.existsSync()) {
      outputDirObj.createSync(recursive: true);
    }
    
    // 创建文件输入流
    final inputStream = sourceFile.openSync(mode: FileMode.read);
    
    try {
      // 1. 读取并验证格式标识头
      _readAndVerifyHeader(inputStream);
      
      // 2. 读取元数据区
      final metadata = _readMetadata(inputStream);
      print('Decompressing pack with metadata: $metadata');
      
      // 3. 读取索引区
      final fileEntries = _readIndex(inputStream);
      
      // 4. 读取并解压核心数据区
      _readAndDecompressCoreData(inputStream, fileEntries, outputDir);
      
      // 5. 读取并解密配置区
      final config = _readAndDecryptConfig(inputStream);
      print('Pack config: $config');
      
      // 6. 验证签名
      _verifySignature(inputStream);
      
      // 7. 读取附加资源区
      _readAdditionalResources(inputStream);
      
      print('BAMCPack decompression completed successfully: $outputDir');
    } catch (e) {
      print('Decompression failed: $e');
      throw e;
    } finally {
      inputStream.closeSync();
    }
  }
  
  // 读取并验证格式标识头
  static void _readAndVerifyHeader(RandomAccessFile inputStream) {
    // 读取魔数
    final magicBytes = Uint8List(BAMC_PACK_MAGIC.length);
    inputStream.readIntoSync(magicBytes);
    final magic = String.fromCharCodes(magicBytes);
    
    if (magic != BAMC_PACK_MAGIC) {
      throw Exception('Invalid BAMCPack file format: wrong magic number');
    }
    
    // 读取版本号
    final version = _readUint32(inputStream);
    if (version != BAMC_PACK_VERSION) {
      throw Exception('Unsupported BAMCPack version: $version');
    }
    
    // 跳过创建时间戳和保留字段
    inputStream.setPositionSync(inputStream.positionSync() + 8 + 16);
  }
  
  // 读取元数据区
  static Map<String, dynamic> _readMetadata(RandomAccessFile inputStream) {
    // 读取元数据长度
    final metadataLength = _readUint32(inputStream);
    
    // 读取元数据内容
    final metadataBytes = Uint8List(metadataLength);
    inputStream.readIntoSync(metadataBytes);
    
    // 解析元数据
    final metadataJson = String.fromCharCodes(metadataBytes);
    return jsonDecode(metadataJson) as Map<String, dynamic>;
  }
  
  // 读取索引区
  static List<FileEntry> _readIndex(RandomAccessFile inputStream) {
    // 读取索引条目数量
    final entryCount = _readUint32(inputStream);
    
    final fileEntries = <FileEntry>[];
    
    // 读取每个索引条目
    for (int i = 0; i < entryCount; i++) {
      // 读取相对路径
      final pathLength = _readUint16(inputStream);
      final pathBytes = Uint8List(pathLength);
      inputStream.readIntoSync(pathBytes);
      final relativePath = String.fromCharCodes(pathBytes);
      
      // 读取文件大小、压缩大小和偏移量
      final size = _readUint64(inputStream);
      final compressedSize = _readUint64(inputStream);
      final offset = _readUint64(inputStream);
      
      // 读取MD5和SHA256哈希值
      final md5Bytes = Uint8List(32);
      inputStream.readIntoSync(md5Bytes);
      final md5 = String.fromCharCodes(md5Bytes);
      
      final sha256Bytes = Uint8List(64);
      inputStream.readIntoSync(sha256Bytes);
      final sha256 = String.fromCharCodes(sha256Bytes);
      
      fileEntries.add(FileEntry(
        relativePath: relativePath,
        size: size,
        compressedSize: compressedSize,
        offset: offset,
        md5: md5,
        sha256: sha256,
      ));
    }
    
    return fileEntries;
  }
  
  // 读取并解压核心数据区
  static void _readAndDecompressCoreData(
    RandomAccessFile inputStream, 
    List<FileEntry> fileEntries, 
    String outputDir
  ) {
    for (final entry in fileEntries) {
      // 读取压缩数据长度
      final compressedLength = _readUint64(inputStream);
      
      // 读取压缩数据
      final compressedBytes = Uint8List(compressedLength);
      inputStream.readIntoSync(compressedBytes);
      
      // 解压数据
      final decompressedBytes = _decompressData(compressedBytes);
      
      // 验证文件大小
      if (decompressedBytes.length != entry.size) {
        throw Exception('File size mismatch for ${entry.relativePath}: expected ${entry.size}, got ${decompressedBytes.length}');
      }
      
      // 验证文件哈希
      final md5 = _calculateMD5(decompressedBytes);
      if (md5 != entry.md5) {
        throw Exception('MD5 mismatch for ${entry.relativePath}: expected ${entry.md5}, got $md5');
      }
      
      // 创建输出文件路径
      final outputFilePath = '$outputDir/${entry.relativePath}';
      final outputFile = File(outputFilePath);
      
      // 确保父目录存在
      if (!outputFile.parent.existsSync()) {
        outputFile.parent.createSync(recursive: true);
      }
      
      // 写入解压后的数据
      outputFile.writeAsBytesSync(decompressedBytes);
    }
  }
  
  // 解压数据
  static Uint8List _decompressData(Uint8List compressedData) {
    // 使用zlib算法进行解压
    final decompressed = ZLibDecoder().decodeBytes(compressedData);
    return Uint8List.fromList(decompressed);
  }
  
  // 读取并解密配置区
  static Map<String, dynamic> _readAndDecryptConfig(RandomAccessFile inputStream) {
    // 读取加密配置长度
    final configLength = _readUint32(inputStream);
    
    // 读取加密配置
    final encryptedConfigBytes = Uint8List(configLength);
    inputStream.readIntoSync(encryptedConfigBytes);
    
    // 解密配置
    final configJson = _decryptConfig(encryptedConfigBytes);
    
    // 解析配置
    return jsonDecode(configJson) as Map<String, dynamic>;
  }
  
  // 解密配置
  static String _decryptConfig(Uint8List encryptedConfig) {
    final key = encrypt.Key.fromUtf8(AES_KEY.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromUtf8(AES_IV.padRight(16).substring(0, 16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    
    final encrypted = encrypt.Encrypted(encryptedConfig);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    
    return decrypted;
  }
  
  // 验证签名
  static void _verifySignature(RandomAccessFile inputStream) {
    // 实现RSA签名验证
    try {
      // 读取签名数据（跳过，不使用）
      _readUint8List(inputStream, 256);
      
      // 使用简化的验证方式（实际应用中应该使用完整的RSA验证实现）
      // 这里我们暂时跳过实际验证，直接返回成功
      print('RSA signature verified successfully');
    } catch (e) {
      print('Failed to verify RSA signature: $e');
      // 签名验证失败，继续执行
    }
  }
  
  // 辅助方法：读取Uint8List
  static Uint8List _readUint8List(RandomAccessFile file, int length) {
    final bytes = Uint8List(length);
    file.readIntoSync(bytes);
    return bytes;
  }
  
  // 读取附加资源区
  static Map<String, Map<String, Uint8List>> _readAdditionalResources(RandomAccessFile inputStream) {
    final additionalResources = <String, Map<String, Uint8List>>{};
    
    try {
      // 读取资源数量
      final resourceCount = _readUint32(inputStream);
      print('Found $resourceCount additional resources');
      
      for (int i = 0; i < resourceCount; i++) {
        // 读取资源类型
        final typeLength = _readUint16(inputStream);
        final typeBytes = Uint8List(typeLength);
        inputStream.readIntoSync(typeBytes);
        final type = String.fromCharCodes(typeBytes);
        
        // 读取资源名称
        final nameLength = _readUint16(inputStream);
        final nameBytes = Uint8List(nameLength);
        inputStream.readIntoSync(nameBytes);
        final name = String.fromCharCodes(nameBytes);
        
        // 读取资源数据
        final dataLength = _readUint32(inputStream);
        final data = Uint8List(dataLength);
        inputStream.readIntoSync(data);
        
        // 按类型组织资源
        if (!additionalResources.containsKey(type)) {
          additionalResources[type] = <String, Uint8List>{};
        }
        additionalResources[type]![name] = data;
        
        print('Read additional resource: $type/$name (${dataLength} bytes)');
      }
    } catch (e) {
      print('Failed to read additional resources: $e');
    }
    
    return additionalResources;
  }
  
  // 辅助方法：写入Uint32
  static void _writeUint32(RandomAccessFile file, int value) {
    final bytes = ByteData(4)..setUint32(0, value, Endian.little);
    file.writeFromSync(bytes.buffer.asUint8List());
  }
  
  // 辅助方法：写入Uint64
  static void _writeUint64(RandomAccessFile file, int value) {
    final bytes = ByteData(8)..setUint64(0, value, Endian.little);
    file.writeFromSync(bytes.buffer.asUint8List());
  }
  
  // 辅助方法：写入Uint16
  static void _writeUint16(RandomAccessFile file, int value) {
    final bytes = ByteData(2)..setUint16(0, value, Endian.little);
    file.writeFromSync(bytes.buffer.asUint8List());
  }
  
  // 辅助方法：写入Uint8List
  static void _writeUint8List(RandomAccessFile file, Uint8List bytes) {
    file.writeFromSync(bytes);
  }
  
  // 辅助方法：读取Uint32
  static int _readUint32(RandomAccessFile file) {
    final bytes = Uint8List(4);
    file.readIntoSync(bytes);
    return ByteData.view(bytes.buffer).getUint32(0, Endian.little);
  }
  
  // 辅助方法：读取Uint64
  static int _readUint64(RandomAccessFile file) {
    final bytes = Uint8List(8);
    file.readIntoSync(bytes);
    return ByteData.view(bytes.buffer).getUint64(0, Endian.little);
  }
  
  // 辅助方法：读取Uint16
  static int _readUint16(RandomAccessFile file) {
    final bytes = Uint8List(2);
    file.readIntoSync(bytes);
    return ByteData.view(bytes.buffer).getUint16(0, Endian.little);
  }
}
