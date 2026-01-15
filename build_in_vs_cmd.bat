@echo off
REM 使用Visual Studio x64 Native Tools Command Prompt构建Flutter应用

REM 检查是否在Visual Studio命令提示符中运行
if not defined VSCMD_VER (
    echo 请在Visual Studio x64 Native Tools Command Prompt中运行此脚本
    echo 1. 点击开始按钮
    echo 2. 搜索 "x64 Native Tools Command Prompt for VS 2022"
    echo 3. 以管理员身份运行
    echo 4. 切换到项目目录
    echo 5. 运行此脚本
    pause
    exit 1
)

echo 正在构建Flutter Windows应用...
flutter build windows

echo 构建完成！
pause