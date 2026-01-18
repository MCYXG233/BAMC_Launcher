import 'package:flutter/material.dart';

// 蔚蓝档案主题实现
class BlueArchiveTheme {
  // 公共常量 - 调整为更适合Windows桌面软件的圆角大小
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 400);
  static const String fontFamily = 'NotoSansSC';
  
  // 渐变背景常量
  static const List<Color> gradientBackgroundLight = [
    Color(0xFFF0F4FF), // 淡蓝色
    Color(0xFFFDE6FF), // 淡粉色
  ];
  static const List<Color> gradientBackgroundDark = [
    Color(0xFF0F172A), // 深蓝黑
    Color(0xFF1E1B4B), // 深紫蓝
  ];
  
  // 浅色主题常量
  // 主色调常量 - 更符合Blue Archive的蓝粉色调
  static const Color primaryColorLight = Color(0xFF4F46E5); // 蓝紫色
  static const Color primaryLightLight = Color(0xFF818CF8); // 浅蓝紫
  static const Color primaryDarkLight = Color(0xFF4338CA); // 深蓝紫
  static const Color primaryContainerLight = Color(0xFF6366F1); // 中蓝紫
  
  // 辅助色常量 - 更符合游戏的粉色调
  static const Color secondaryColorLight = Color(0xFFEC4899); // 亮粉色
  static const Color secondaryLightLight = Color(0xFFF9A8D4); // 浅粉色
  static const Color successColorLight = Color(0xFF22C55E); // 绿色
  static const Color warningColorLight = Color(0xFFEAB308); // 黄色
  static const Color errorColorLight = Color(0xFFEF4444); // 红色
  
  // 中性色常量 - 更柔和的色调
  static const Color backgroundColorLight = Color(0xFFF8FAFC); // 浅灰
  static const Color surfaceColorLight = Color(0xFFFFFFFF); // 纯白
  static const Color textPrimaryLight = Color(0xFF1E293B); // 深灰
  static const Color textSecondaryLight = Color(0xFF475569); // 中灰
  static const Color textLightLight = Color(0xFF94A3B8); // 浅灰
  static const Color borderColorLight = Color(0xFFE2E8F0); // 边框灰
  static const Color cardShadowColorLight = Color(0xFFCBD5E1); // 卡片阴影色
  
  // 深色主题常量
  // 主色调常量 - 更符合Blue Archive的深色蓝紫色调
  static const Color primaryColorDark = Color(0xFF8B5CF6); // 深紫
  static const Color primaryLightDark = Color(0xFFA78BFA); // 浅紫
  static const Color primaryDarkDark = Color(0xFF7C3AED); // 深蓝紫
  static const Color primaryContainerDark = Color(0xFF9333EA); // 中紫
  
  // 辅助色常量 - 更符合游戏的深色粉色调
  static const Color secondaryColorDark = Color(0xFFEC4899); // 亮粉色
  static const Color secondaryLightDark = Color(0xFFF472B6); // 中粉色
  static const Color successColorDark = Color(0xFF10B981); // 绿色
  static const Color warningColorDark = Color(0xFFFBBF24); // 黄色
  static const Color errorColorDark = Color(0xFFEF4444); // 红色
  
  // 中性色常量 - 更柔和的深色
  static const Color backgroundColorDark = Color(0xFF0F172A); // 深蓝黑
  static const Color surfaceColorDark = Color(0xFF1E293B); // 夜空灰
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // 月光白
  static const Color textSecondaryDark = Color(0xFFE2E8F0); // 星辰灰
  static const Color textLightDark = Color(0xFF94A3B8); // 浅灰
  static const Color borderColorDark = Color(0xFF475569); // 边框灰
  static const Color cardShadowColorDark = Color(0xFF1E293B); // 卡片阴影色
  
  // 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      // 主色调配置
      primarySwatch: Colors.blue,
      primaryColor: primaryColorLight,
      primaryColorLight: primaryLightLight,
      primaryColorDark: primaryDarkLight,
      brightness: Brightness.light,
      
      // 色彩方案
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        cardColor: surfaceColorLight,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColorLight,
        primaryContainer: primaryContainerLight,
        secondary: secondaryColorLight,
        secondaryContainer: secondaryLightLight,
        surface: surfaceColorLight,
        error: errorColorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        // 主标题
        headlineLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: primaryColorLight,
          fontFamily: fontFamily,
          letterSpacing: -0.5,
        ),
        // 副标题
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: primaryColorLight,
          fontFamily: fontFamily,
          letterSpacing: -0.25,
        ),
        // 卡片标题
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: primaryContainerLight,
          fontFamily: fontFamily,
        ),
        // 正文大
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: textSecondaryLight,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 正文
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: textSecondaryLight,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 辅助文字
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: textLightLight,
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
          color: primaryColorLight,
          fontFamily: fontFamily,
          letterSpacing: 0.1,
        ),
      ),
      
      // 应用栏主题 - 更适合Windows桌面软件
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColorLight,
        elevation: 1.0,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // 按钮主题 - 更符合Blue Archive的渐变按钮设计
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shadowColor: primaryColorLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
          textStyle: const TextStyle(
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
          foregroundColor: primaryColorLight,
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),
      
      // 填充按钮主题 - 更符合游戏的圆角设计
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shadowColor: primaryColorLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
        ),
      ),
      
      // 卡片主题 - 更符合Blue Archive的圆润设计
      cardTheme: CardThemeData(
        elevation: 2.0,
        shadowColor: cardShadowColorLight.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: borderColorLight, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        color: surfaceColorLight,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryContainerLight, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColorLight, width: 2.0),
        ),
        hintStyle: const TextStyle(
          color: textLightLight,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryLight,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        helperStyle: const TextStyle(
          color: textLightLight,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        errorStyle: const TextStyle(
          color: errorColorLight,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        isDense: true,
        filled: true,
        fillColor: surfaceColorLight,
      ),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: textSecondaryLight,
        size: 24.0,
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: borderColorLight,
        thickness: 1.0,
        space: 16.0,
      ),
      
      // 列表主题
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        iconColor: textSecondaryLight,
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColorLight;
          }
          return borderColorLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLightLight;
          }
          return borderColorLight;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColorLight,
        inactiveTrackColor: borderColorLight,
        thumbColor: primaryColorLight,
        overlayColor: primaryLightLight.withOpacity(0.3),
        activeTickMarkColor: primaryColorLight,
        inactiveTickMarkColor: Colors.transparent,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColorLight,
        linearTrackColor: borderColorLight,
        circularTrackColor: borderColorLight,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        surfaceTintColor: surfaceColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
          fontFamily: fontFamily,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14.0,
          color: textSecondaryLight,
          fontFamily: fontFamily,
          height: 1.5,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColorLight,
        elevation: 0.0,
        selectedItemColor: primaryColorLight,
        unselectedItemColor: textSecondaryLight,
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          color: textSecondaryLight,
          fontFamily: fontFamily,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      
      // 底部应用栏主题
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: surfaceColorLight,
        elevation: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorLight,
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
      
      // 页面过渡主题 - 使用更符合桌面软件的淡入淡出过渡效果
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // 所有平台统一使用淡入淡出过渡，更符合桌面软件体验
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // 扩展面板主题
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surfaceColorLight,
        collapsedBackgroundColor: surfaceColorLight,
        textColor: textPrimaryLight,
        collapsedTextColor: textSecondaryLight,
        iconColor: textSecondaryLight,
        collapsedIconColor: textLightLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      
      // 主题扩展
      extensions: const <ThemeExtension>[_BlueArchiveThemeExtension()],
      
      // 视觉密度
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      // 主色调配置
      primarySwatch: Colors.blue,
      primaryColor: primaryColorDark,
      primaryColorLight: primaryLightDark,
      primaryColorDark: primaryDarkDark,
      brightness: Brightness.dark,
      
      // 色彩方案
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        cardColor: surfaceColorDark,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryColorDark,
        primaryContainer: primaryContainerDark,
        secondary: secondaryColorDark,
        secondaryContainer: secondaryLightDark,
        surface: surfaceColorDark,
        error: errorColorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        // 主标题
        headlineLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: primaryColorDark,
          fontFamily: fontFamily,
          letterSpacing: -0.5,
        ),
        // 副标题
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: primaryColorDark,
          fontFamily: fontFamily,
          letterSpacing: -0.25,
        ),
        // 卡片标题
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: primaryContainerDark,
          fontFamily: fontFamily,
        ),
        // 正文大
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: textSecondaryDark,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 正文
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: textSecondaryDark,
          fontFamily: fontFamily,
          height: 1.5,
        ),
        // 辅助文字
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: textLightDark,
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
          color: primaryColorDark,
          fontFamily: fontFamily,
          letterSpacing: 0.1,
        ),
      ),
      
      // 应用栏主题 - 更适合Windows桌面软件
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColorDark,
        elevation: 1.0,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 24.0,
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // 按钮主题 - 更符合Blue Archive的渐变按钮设计
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorDark,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shadowColor: primaryColorDark.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
          textStyle: const TextStyle(
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
          foregroundColor: primaryColorDark,
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),
      
      // 填充按钮主题 - 更符合游戏的圆角设计
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColorDark,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shadowColor: primaryColorDark.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
          animationDuration: animationDuration,
        ),
      ),
      
      // 卡片主题 - 更符合Blue Archive的圆润设计
      cardTheme: CardThemeData(
        elevation: 2.0,
        shadowColor: cardShadowColorDark.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: borderColorDark, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        color: surfaceColorDark,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryContainerDark, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColorDark, width: 2.0),
        ),
        hintStyle: const TextStyle(
          color: textLightDark,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 14.0,
          fontFamily: fontFamily,
        ),
        helperStyle: const TextStyle(
          color: textLightDark,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        errorStyle: const TextStyle(
          color: errorColorDark,
          fontSize: 12.0,
          fontFamily: fontFamily,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        isDense: true,
        filled: true,
        fillColor: surfaceColorDark,
      ),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: textSecondaryDark,
        size: 24.0,
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: borderColorDark,
        thickness: 1.0,
        space: 16.0,
      ),
      
      // 列表主题
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        iconColor: textSecondaryDark,
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColorDark;
          }
          return borderColorDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLightDark;
          }
          return borderColorDark;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColorDark,
        inactiveTrackColor: borderColorDark,
        thumbColor: primaryColorDark,
        overlayColor: primaryLightDark.withOpacity(0.3),
        activeTickMarkColor: primaryColorDark,
        inactiveTickMarkColor: Colors.transparent,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColorDark,
        linearTrackColor: borderColorDark,
        circularTrackColor: borderColorDark,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        surfaceTintColor: surfaceColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          fontFamily: fontFamily,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14.0,
          color: textSecondaryDark,
          fontFamily: fontFamily,
          height: 1.5,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColorDark,
        elevation: 0.0,
        selectedItemColor: primaryColorDark,
        unselectedItemColor: textSecondaryDark,
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          color: textSecondaryDark,
          fontFamily: fontFamily,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      
      // 底部应用栏主题
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: surfaceColorDark,
        elevation: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorDark,
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
      
      // 页面过渡主题 - 使用更符合桌面软件的淡入淡出过渡效果
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // 所有平台统一使用淡入淡出过渡，更符合桌面软件体验
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // 扩展面板主题
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surfaceColorDark,
        collapsedBackgroundColor: surfaceColorDark,
        textColor: textPrimaryDark,
        collapsedTextColor: textSecondaryDark,
        iconColor: textSecondaryDark,
        collapsedIconColor: textLightDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      
      // 主题扩展
      extensions: const <ThemeExtension>[_BlueArchiveThemeExtension()],
      
      // 视觉密度
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // 主题数据（兼容现有代码，默认浅色主题）
  static ThemeData get themeData => lightTheme;
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