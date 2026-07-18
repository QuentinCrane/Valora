# Valora 文档索引

这个目录收纳项目说明、技术指南、产品规格和历史迭代记录。README 保持简洁，细节文档按用途分组放在这里。

## 常用文档

- [用户使用教程](guides/USER_GUIDE.md)
- [技术与构建指南](guides/TECHNICAL_GUIDE.md)
- [Flutter Release APK 编译流程与问题记录](guides/BUILD_PROCESS.md)
- [开源发布检查清单](guides/OPEN_SOURCE_RELEASE.md)
- [第三方开源声明](../THIRD_PARTY_NOTICES.md)
- [v0.80 GitHub Release 文案](v80_github_release_notes.md)
- [发布历史](../CHANGELOG.md)

## 目录说明

- `guides/`：面向使用、开发和构建的常用指南。
- `product/`：产品规格、迁移说明、参考实现和设计背景资料。
- `stickers/`：贴纸封面、抠图、边缘优化等图片处理相关笔记。
- `assets/`：文档中使用的图片资源。
- `../THIRD_PARTY_NOTICES.md`：仓库根目录的第三方依赖与开源组件声明，包含必要版权声明和许可文本。
- `assets/screenshots/`：README 和发布页可引用的脱敏截图目录。

版本变更以根目录的 `CHANGELOG.md` 和 GitHub Releases 为准。详细的迭代过程报告不再占用默认分支的文档树，仍可通过 Git 历史追溯。

## 开源维护建议

如果后续文档继续增加，建议优先放入已有分组。只有当某类文档超过当前分组语义时，再新增目录，避免 `docs/` 根目录再次变成文件堆。
