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

if not exist android\gradlew.bat (
  echo [INFO] 未检测到 Gradle Wrapper，尝试用 flutter create 补齐 Android 构建壳。
  flutter create --platforms=android --project-name valora_assets --org com.valora .
  echo [INFO] 重新应用Valora Android Patch 文件。
  xcopy /E /I /Y tooling\android_patch\app android\app >nul
  copy /Y tooling\android_patch\build.gradle android\build.gradle >nul
  copy /Y tooling\android_patch\settings.gradle android\settings.gradle >nul
  copy /Y tooling\android_patch\gradle.properties android\gradle.properties >nul
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
