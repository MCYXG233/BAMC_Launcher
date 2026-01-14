import 'package:flutter/foundation.dart';

// 整合包格式枚举
enum PackFormat {
  bamcpack,
  pclpack,
  mrpack,
  mcbbs,
  unknown,
}

// 格式识别与解析服务
class PackFormatDetector {
  Future<PackFormat> detectFormat(String filePath) async {
    // 使用 compute 函数在后台线程执行
    return await compute(_detectFormatInBackground, filePath);
  }
  
  static PackFormat _detectFormatInBackground(String filePath) {
    // 格式检测逻辑
    if (filePath.endsWith('.bamcpack')) {
      return PackFormat.bamcpack;
    } else if (filePath.endsWith('.pclpack')) {
      return PackFormat.pclpack;
    } else if (filePath.endsWith('.mrpack')) {
      return PackFormat.mrpack;
    } else if (filePath.endsWith('.zip') || filePath.endsWith('.7z')) {
      return PackFormat.mcbbs;
    }
    return PackFormat.unknown;
  }
}
