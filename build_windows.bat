@echo off
setlocal
REM Valora Windows 构建脚本
REM 需要提前安装 Flutter stable、Android Studio / Android SDK，并把 flutter 加入 PATH。

where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERROR] 没有找到 flutter 命令，请先安装 Flutter 并配置 PATH。
  pause
  exit /b 1
)

if not exist android\app\build.gradle (
  echo [ERROR] Android 平台文件不完整，已停止以避免覆盖本地原生修改。
  echo [HINT] Git 检出中请运行：git restore --source=HEAD --worktree -- android
  echo [HINT] 若当前目录不是 Git 检出，请从干净的仓库副本恢复 android 目录。
  exit /b 1
)

if not exist android\gradlew.bat (
  echo [ERROR] 未检测到 Gradle Wrapper，已停止以避免覆盖本地原生修改。
  echo [HINT] Git 检出中请运行：git restore --source=HEAD --worktree -- android
  echo [HINT] 若当前目录不是 Git 检出，请从干净的仓库副本恢复 android 目录。
  exit /b 1
)

echo [INFO] 检查 Flutter 环境...
flutter doctor
if errorlevel 1 (
  echo [WARN] flutter doctor 返回异常，请根据上方提示修复环境后重试。
)

echo [INFO] 获取依赖...
flutter pub get
if errorlevel 1 goto :fail

echo [INFO] 静态分析...
flutter analyze
if errorlevel 1 goto :fail

echo [INFO] 构建 Debug APK...
flutter build apk --debug
if errorlevel 1 goto :fail

echo.
echo [SUCCESS] APK 构建完成：build\app\outputs\flutter-apk\app-debug.apk
pause
exit /b 0

:fail
echo.
echo [ERROR] 构建失败。请把上方错误复制给 Codex/ChatGPT 继续修复。
pause
exit /b 1
