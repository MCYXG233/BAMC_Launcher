import 'package:logger/logger.dart';

/// 全局日志记录器实例
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 简化的日志函数
void logD(String message) => logger.d(message);
void logI(String message) => logger.i(message);
void logW(String message) => logger.w(message);
void logE(String message, [dynamic error, StackTrace? stackTrace]) => logger.e(message, error: error, stackTrace: stackTrace);
