# BAMCLauncher

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2+-blue.svg)](https://dart.dev/)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

一个基于Flutter开发的Minecraft启动器，具有Blue Archive主题风格，支持自定义.bamcpack模组包格式和P2P网络功能。

## ✨ 功能特性

### 🎮 核心功能
- **多实例管理**：创建、编辑、删除多个游戏实例
- **自定义模组包格式**：支持.bamcpack格式，具有分层压缩和数字签名
- **P2P网络功能**：
  - UDP广播发现
  - TCP连接建立
  - NAT穿透支持
- **正版登录**：支持Microsoft OAuth 2.0认证
- **离线模式**：无需网络连接即可游玩

### 🎨 界面设计
- **Blue Archive主题**：采用Blue Archive游戏的视觉风格
- **动画效果**：流畅的动画过渡和交互反馈
- **响应式设计**：适配不同屏幕尺寸

### 🔧 实用工具
- **游戏日志解析**：实时分析游戏日志，检测错误和崩溃
- **Java环境验证**：自动检测并验证Java环境
- **文件系统适配**：支持跨平台文件路径处理
- **微内核+插件架构**：便于扩展新功能

## 🚀 安装方法

### 系统要求
- Windows 10/11 (64位)
- macOS 10.15+ (64位)
- Linux (64位)
- Flutter 3.16+ 和 Dart 3.2+ (开发环境)

### 编译安装

1. **克隆仓库**
```bash
git clone https://github.com/MCYXG233/BAMC_Launcher.git
cd BAMC_Launcher
```

2. **安装依赖**
```bash
flutter pub get
```

3. **编译运行**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

4. **构建发布版本**
```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 📖 使用说明

### 首次启动
1. 选择登录方式：
   - **Microsoft登录**：使用正版Minecraft账号登录
   - **离线模式**：创建本地离线账号

2. 创建游戏实例：
   - 点击"新建实例"
   - 选择Minecraft版本
   - 配置Java路径和内存设置
   - 点击"创建"

### 导入模组包
1. 点击"模组包管理"
2. 选择"导入模组包"
3. 选择.bamcpack文件
4. 等待导入完成

### P2P网络功能
1. 确保所有设备在同一局域网
2. 点击"P2P网络"
3. 选择"搜索设备"
4. 选择要连接的设备
5. 开始文件共享或联机游戏

## 🔧 开发指南

### 项目结构
```
├── lib/                 # 主要源代码
│   ├── components/      # UI组件
│   ├── models/          # 数据模型
│   ├── services/        # 服务层
│   ├── theme/           # 主题配置
│   ├── utils/           # 工具类
│   ├── views/           # 页面视图
│   └── main.dart        # 应用入口
├── test/                # 测试代码
├── pubspec.yaml         # 依赖配置
├── pubspec.lock         # 依赖锁定文件
├── LICENSE              # MIT许可证
└── README.md            # 项目文档
```

### 核心服务

#### 1. 认证服务 (`auth_service.dart`)
- Microsoft OAuth 2.0认证
- Mojang账号认证（已废弃）
- 本地账号管理

#### 2. 实例管理 (`instance_manager.dart`)
- 实例创建、编辑、删除
- 游戏日志解析和错误检测
- Java环境验证

#### 3. P2P网络 (`p2p_network_manager.dart`)
- UDP广播实现
- TCP连接管理
- NAT穿透支持

#### 4. 模组包处理 (`bamc_pack_compressor.dart`)
- .bamcpack格式压缩/解压缩
- RSA数字签名验证
- 分层压缩算法

### 自定义主题

项目采用Blue Archive主题，可在`theme/blue_archive_theme.dart`中修改主题配置：

- 颜色方案
- 字体样式
- 动画效果

## 📄 开源协议

本项目采用 **MIT License** 开源协议。

### MIT License 说明

MIT许可证是一种宽松的开源许可证，允许：
- 商业使用
- 修改
- 分发
- 私人使用

只需保留原作者的版权声明和许可证文本即可。

### 为什么选择MIT License？

1. **宽松自由**：允许几乎所有使用方式，包括商业用途
2. **简单易懂**：许可证文本简洁明了，易于理解
3. **广泛采用**：被众多知名项目使用，如Node.js、React等
4. **兼容性好**：与其他许可证兼容性强，便于与其他项目集成
5. **保护作者**：明确声明不承担任何 liability

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 提交规范

1. **Issue**：
   - 清晰描述问题
   - 提供复现步骤
   - 附上相关截图（如有）

2. **Pull Request**：
   - 遵循项目代码风格
   - 编写清晰的提交信息
   - 确保所有测试通过
   - 描述修改内容和原因

## 📞 联系方式

- **项目地址**：https://github.com/MCYXG233/BAMC_Launcher
- **Issues**：https://github.com/MCYXG233/BAMC_Launcher/issues

## 📝 更新日志

### v1.0.1 (2026-01-18)
- **整合包功能移到实例**：将整合包导入/导出功能集成到实例管理中
- **修复联机功能异常**：修复P2P网络连接问题，确保联机功能正常工作
- **优化子页面UI**：移除安卓特有的设计元素，遵循Windows 11设计规范
- **实现液态玻璃效果**：为界面添加现代化的毛玻璃效果
- **设置背景图**：添加主题渐变背景，增强视觉效果
- **修复withValues使用错误**：将所有withValues(alpha: x)替换为withOpacity(x)

### v1.0.0 (2026-01-14)
- 初始版本发布
- 实现核心功能
- 支持.bamcpack格式
- 支持P2P网络功能
- 支持Microsoft登录

## 📄 许可证

[MIT License](LICENSE)
