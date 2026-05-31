# Valora 开源发布检查清单

这份清单用于把当前本地项目整理成一个适合公开放到 GitHub 的仓库。

## 推荐仓库根目录

建议把 `valora_app/` 的内容作为 GitHub 仓库根目录。不要在远端仓库里再套一层 `valora_app/`，这样 `.github/workflows/flutter.yml` 才会直接生效。

不要把外层工作区一起推上去，尤其是：

- `archives/`：历史压缩包和交付包。
- `valora-site/`：宣传站点，继续单独部署到自己的服务器。
- 本地构建产物、APK、AAB、ZIP。
- 任何临时备份、私有截图或账号配置。

## 已补齐的开源文件

- `README.md`：项目介绍、功能、结构、构建入口和发布建议。
- `LICENSE`：默认 Apache License 2.0。
- `NOTICE`：项目归属和补充声明。
- `CONTRIBUTING.md`：贡献流程、检查命令和隐私要求。
- `SECURITY.md`：安全报告方式和敏感区域。
- `CHANGELOG.md`：公开版本变更记录入口。
- `.github/ISSUE_TEMPLATE/`：Bug 与功能请求模板。
- `.github/pull_request_template.md`：PR 描述模板。
- `.github/workflows/flutter.yml`：GitHub Actions 检查。
- `.editorconfig` / `.gitattributes`：跨平台文本和换行规范。

## 发布前必查

运行：

```bash
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

确认不要提交：

- `android/local.properties`
- `.env` / `.env.*`
- `key.properties`
- `*.jks` / `*.keystore` / `*.p12` / `*.pem`
- `build/`
- `.dart_tool/`
- `.gradle/`
- `*.apk` / `*.aab` / `*.zip`

当前 `.gitignore` 已覆盖这些路径。用 Git 正常提交时它们不会进入仓库；如果通过网页手动上传文件，仍要自己避开。

APK 安装包不提交到源码仓库。需要公开下载时，在 GitHub Releases 中上传附件，建议命名为：

```text
Valora-v0.79.0-android.apk
```

## 展示素材建议

README 现在有产品定位、功能清单、页面结构和应用图标，但正式公开时最好再补充脱敏截图。推荐截图：

- 首页资产总览。
- 资产详情和生命周期进度。
- 分析页趋势和排行。
- 封面/贴纸编辑。
- 设置里的备份、同步和小组件入口。

截图放到：

```text
docs/assets/screenshots/
```

截图要求：

- 使用示例数据，不使用真实个人资产。
- 不出现账号、WebDAV 地址、服务器域名或本机路径。
- 尽量使用统一设备尺寸，推荐 Android 手机竖屏截图。

## GitHub 发布步骤

1. 在 GitHub 创建空仓库。
2. 在本地进入 `valora_app/`，并把这里作为仓库根目录。
3. 初始化并提交：

```bash
git init
git add .
git commit -m "chore: prepare open-source release"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

4. 在 GitHub 仓库设置里确认：

- Actions 已开启。
- Security advisories 已开启。
- 默认分支是 `main`。
- 仓库描述、Topics、License 显示正常。

## 仍建议人工决定的事项

- 是否继续使用 Apache License 2.0，还是改为 MIT / GPL-3.0 / 其他协议。
- 是否公开历史报告和 AI 协作提示词。
- 是否在发布前补充脱敏截图。
- 是否添加首个 `v0.79.0` Git tag 和 Release notes，并把 APK 上传到对应 Release。
