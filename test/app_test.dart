import 'package:flutter_test/flutter_test.dart';
import 'package:bamclauncher/main.dart';

void main() {
  testWidgets('Basic app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BAMCLauncherApp());

    // Verify that our app title is displayed.
    expect(find.text('BAMCLauncher'), findsOneWidget);
    
    // Verify welcome text is displayed
    expect(find.text('欢迎使用 BAMCLauncher'), findsOneWidget);
    
    // Verify subtitle is displayed
    expect(find.text('轻量跨平台、二次元风格的 Minecraft 启动器'), findsOneWidget);
    
    // Verify button texts are displayed
    expect(find.text('新建实例'), findsOneWidget);
    expect(find.text('导入整合包'), findsOneWidget);
    
    // Verify section titles are displayed
    expect(find.text('我的实例'), findsOneWidget);
    expect(find.text('P2P 联机'), findsOneWidget);
    
    // Verify instance cards are displayed
    expect(find.text('Example Instance'), findsOneWidget);
    expect(find.text('Creative World'), findsOneWidget);
    
    // Verify P2P cards are displayed
    expect(find.text('创建房间'), findsOneWidget);
    expect(find.text('加入房间'), findsOneWidget);
  });
}
