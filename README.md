# 月薪喵 Codex Skin

中文 · [English](./README.en.md)

作者：终端极客 · [GitHub 仓库](https://github.com/mcgfdata/codex-skin-salary-cat)

只使用一张月薪喵素材制作的 [Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 主题包。

<p align="center">
  <img src="./presets/preset-yuexinmiao/background.jpg" alt="月薪喵主题背景预览" width="900">
</p>

> 这是一个轻量主题包，不把 Dream Skin 基础运行时复制进仓库，也不会修改官方 Codex 安装包。完整安装器会在缺少运行时时仅从官方上游仓库安装依赖。

## 让 Codex 自动安装

在新的 Codex 任务中直接发送：

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

仓库从 `0.2.0` 起同时是标准 Codex Plugin 和 Skill。Codex 可以安装 [`skills/codex-skin-salary-cat`](./skills/codex-skin-salary-cat/SKILL.md)，读取 [`codex-install.json`](./codex-install.json)，再执行完整安装入口。首次安装基础运行时可能需要关闭或重启 Codex，代理必须把“已安装”和“已应用”分开报告。

完整说明见 [`INSTALL_WITH_CODEX.md`](./INSTALL_WITH_CODEX.md)。

## 兼容性

- 主题格式：Codex Dream Skin schema version 1
- 已用上游运行时 `1.2.0` 的 `--check-payload` 校验通过
- 目标平台：macOS、Windows
- 安装位置：
  - macOS: `~/Library/Application Support/CodexDreamSkinStudio/themes/preset-yuexinmiao`
  - Windows: `%LOCALAPPDATA%\CodexDreamSkin\themes\preset-yuexinmiao`

上游运行时以后如果修改主题 schema，本仓库也需要同步适配。

## 安装

1. 从本仓库 Releases 下载月薪喵安装包并完整解压，或者克隆本仓库。
2. 运行完整安装入口；它会检测并按需安装官方基础运行时：
   - macOS：双击 [`Setup.command`](./Setup.command)
   - Windows：双击 [`Setup.cmd`](./Setup.cmd)，或运行 [`Setup.ps1`](./Setup.ps1)
3. 只安装主题、已有基础运行时的用户，也可运行 `Install.command` / `Install.cmd`。

完整安装器会先处理官方基础运行时，再校验和安装预设。macOS 在当前任务不能安全重启时可使用：

```bash
./scripts/setup-skin-macos.sh --no-apply
```

它会把月薪喵设为活动主题，下次从 Codex Dream Skin 启动时直接生效。

只复制主题、不自动应用：

```bash
./scripts/install-theme-macos.sh --no-apply
```

```powershell
.\Install.ps1 -NoApply
```

macOS 如果拦截首次打开，可在 Finder 中右键 `Install.command` 后选择「打开」。安装器不需要管理员权限。

## 单图构图说明

仓库只使用 [`source/salary-cat-source.png`](./source/salary-cat-source.png)，不会生成新主体或引入第二张画面。

源图尺寸为 `1942 × 809`，宽高比约 `2.40:1`；Dream Skin 推荐背景是 `2560 × 1440`（`16:9`）。当前裁切会舍弃约 26% 的横向画幅，几乎都来自左侧留白，再把约 `1438 × 809` 的有效画面放大到 `2560 × 1440`。它优先保留右侧月薪喵主体和左侧原生 UI 安全区，但不会增加真实图像细节。这一点与原图的一比一完整画幅存在客观偏差，过程中没有改画或补画。

当前主题参数：

- 主体焦点：`focusX 0.72` / `focusY 0.48`
- 安全区：`left`
- 任务页模式：`ambient`
- 外观：`auto`

## 重新生成与校验

需要 Python 3.10 或更高版本：

```bash
python3 -m pip install -r requirements.txt
python3 scripts/build_presets.py
python3 scripts/validate_theme.py
```

生成公开 Release 前还要通过素材授权检查：

```bash
python3 scripts/validate_theme.py --release
```

构建本地安装 ZIP：

```bash
python3 scripts/package_release.py \
  --output dist/codex-skin-salary-cat-0.2.0.zip
```

## 仓库内容

- `source/salary-cat-source.png`：唯一原始素材
- `presets/preset-yuexinmiao/`：可安装主题，只含 `background.jpg` 和 `theme.json`
- `scripts/build_presets.py`：从唯一素材生成 16:9 背景
- `scripts/validate_theme.py`：校验图片限制、主题 schema 和发布授权状态
- `scripts/package_release.py`：生成保留 macOS 可执行权限的安装 ZIP
- `Setup.command` / `Setup.ps1`：包含官方基础运行时检测的完整安装入口
- `.codex-plugin/plugin.json` / `SKILL.md`：标准 Codex Plugin/Skill 入口
- `skills/codex-skin-salary-cat/`：供内置 GitHub Skill 安装器使用
- `AGENTS.md` / `codex-install.json`：给 Codex 代理读取的安装协议
- `INSTALL_WITH_CODEX.md`：新任务中的一句话安装说明
- `发布前填写表.md`：项目所有者需要补充的发布信息

## 许可与声明

- 代码与文档：MIT，见 [`LICENSE`](./LICENSE)
- 图片素材：CC BY 4.0，见 [`ASSET-LICENSE.md`](./ASSET-LICENSE.md)
- 额外声明：见 [`NOTICE.md`](./NOTICE.md)
- 本项目非 OpenAI 官方产品；Codex 及相关标识归各自权利人所有

图片素材按 CC BY 4.0 发布，使用或再分发时请保留“月薪喵主题作者：终端极客”署名。
