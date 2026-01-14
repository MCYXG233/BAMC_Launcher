import 'package:flutter/material.dart';

// 蔚蓝档案主题实现
class BlueArchiveTheme {
  // 主色调常量
  static const Color primaryColor = Color(0xFF1E3A8A); // 静谧蓝
  static const Color primaryLight = Color(0xFF60A5FA); // 浅海蓝
  static const Color primaryDark = Color(0xFF1E40AF); // 深海蓝
  static const Color primaryContainer = Color(0xFF3B82F6); // 晴空蓝
  
  // 辅助色常量
  static const Color secondaryColor = Color(0xFFF472B6); // 樱花粉
  static const Color secondaryLight = Color(0xFFFBCFE8); // 浅粉
  static const Color successColor = Color(0xFF34D399); // 草绿色
  static const Color warningColor = Color(0xFFF59E0B); // 暖橙色
  static const Color errorColor = Color(0xFFEF4444); // 错误红
  
  // 中性色常量
  static const Color backgroundColor = Color(0xFFF8FAFC); // 月光白
  static const Color surfaceColor = Color(0xFFFFFFFF); // 纯白
  static const Color textPrimary = Color(0xFF1F2937); // 深灰
  static const Color textSecondary = Color(0xFF6B7280); // 星辰灰
  static const Color textLight = Color(0xFF9CA3AF); // 浅灰
  static const Color borderColor = Color(0xFFE5E7EB); // 边框灰
  
  // 圆角常量
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration animationDurationSlow = Duration(milliseconds: 350);
  
  // 字体常量
  static const String fontFamily = 'NotoSansSC';
  
  static ThemeData get themeData {
    return ThemeData(
      // 主色调配置
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      
      // 色彩方案
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        cardColor: surfaceColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: secondaryColor,
        secondaryContainer: secondaryLight,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      
      // 文本主题
      textTheme: TextTheme(
        // 主标题
        headlineLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontFamily: fontFamily,
          letterSpacing: -0.5,
        ),
        // 副标题
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontFamily: fontFamily,
          letterSpacing: -0.25,
        ),
        // 卡片标题
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: primaryContainer,
          fontFamily: fontFamily,
        ),
        // 正文大
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 正文
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 辅助文字
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: textLight,
          fontFamily: fontFamily,
        ),
        // 按钮文字
        labelLarge: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: fontFamily,
          letterSpacing: 0.1,
        ),
        // 按钮文字（次要）
        labelMedium: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: primaryColor,
          fontFamily: fontFamily,
          letterSpacing: 0.1,
        ),
      ),
      
      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0.0,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(borderRadiusMedium),
          ),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          textStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
        ),
      ),
      
      // 填充按钮主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          textStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0.0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: borderColor, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: surfaceColor,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryContainer, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 2.0),
        ),
        hintStyle: TextStyle(
          color: textLight,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        helperStyle: TextStyle(
          color: textLight,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        errorStyle: TextStyle(
          color: errorColor,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        isDense: true,
        filled: true,
        fillColor: surfaceColor,
      ),
      
      // 图标主题
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 24.0,
      ),
      
      // 分割线主题
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1.0,
        space: 16.0,
      ),
      
      // 列表主题
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        iconColor: textSecondary,
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return borderColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return borderColor;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: borderColor,
        thumbColor: primaryColor,
        overlayColor: primaryLight.withValues(alpha: 0.3 * 255),
        activeTickMarkColor: primaryColor,
        inactiveTickMarkColor: Colors.transparent,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        surfaceTintColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14.0,
          color: textSecondary,
          fontFamily: fontFamily,
          height: 1.5,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0.0,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          color: textSecondary,
          fontFamily: fontFamily,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      
      // 底部应用栏主题
      bottomAppBarTheme: BottomAppBarThemeData(
        color: surfaceColor,
        elevation: 0.0,
        shape: const CircularNotchedRectangle(),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        sizeConstraints: const BoxConstraints(
          minWidth: 56.0,
          minHeight: 56.0,
        ),
      ),
      
      // 页面过渡主题
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // 扩展面板主题
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surfaceColor,
        collapsedBackgroundColor: surfaceColor,
        textColor: textPrimary,
        collapsedTextColor: textSecondary,
        iconColor: textSecondary,
        collapsedIconColor: textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      
      // 主题扩展
      extensions: <ThemeExtension>[_BlueArchiveThemeExtension()],
      
      // 视觉密度
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // 禁用动画（用于测试或性能优化）
      // disableAnimations: true,
    );
  }
}

// 自定义主题扩展
class _BlueArchiveThemeExtension extends ThemeExtension<_BlueArchiveThemeExtension> {
  const _BlueArchiveThemeExtension();
  
  @override
  _BlueArchiveThemeExtension copyWith() => const _BlueArchiveThemeExtension();
  
  @override
  _BlueArchiveThemeExtension lerp(ThemeExtension<_BlueArchiveThemeExtension>? other, double t) {
    if (other is! _BlueArchiveThemeExtension) {
      return this;
    }
    return const _BlueArchiveThemeExtension();
  }
}
