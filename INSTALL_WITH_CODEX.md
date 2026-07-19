# 用 Codex 设置月薪喵

在一个新的 Codex 任务中直接发送：

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

用户口令只需保持上面这一句，不需要描述 Skill、bootstrap 或任何工具。如果本地没有 `codex-skin-salary-cat`，Codex 应：

1. 调用系统自带的 `skill-installer`，从仓库 `mcgfdata/codex-skin-salary-cat` 获取路径 `skills/codex-skin-salary-cat`。
2. 立即读取获取到的 `SKILL.md`，在同一个任务中继续运行平台 bootstrap，不要求用户再发一条消息。
3. 如果系统 Skill 不可用，则使用系统 HTTPS 工具下载 GitHub 源码 ZIP，直接执行完整 Setup；不要求 Git。

完成自举后：

1. 检测 macOS 或 Windows。
2. 检查 Codex Dream Skin 基础运行时。
3. 已有运行时则保存两套月薪喵样式，并尝试应用默认样式“月薪喵 · 今日营业”。
4. 没有运行时则只从官方上游仓库准备依赖，再保存本主题的两套样式。
5. 校验 `preset-yuexinmiao` 与 `preset-yuexinmiao-payday` 都已进入主题库。
6. 分别报告“已安装”和“已应用”，并说明可在“已保存的主题”中自行切换。

完整安装入口是 `Setup.command`（macOS）和 `Setup.ps1`（Windows），不是只复制主题的 `Install.*`。

普通用户无需提前安装 Git、Python 或 Pillow。macOS 不需要额外 Node.js；Windows 缺少 Node.js 22+ 时会自动下载官方 ZIP、验证 SHA-256，并安装到当前用户目录。用户只需已有官方 Codex Desktop 和可用的 HTTPS 网络。

macOS 第一次设置基础运行时时只显示一次系统确认。确认后，当前任务把后续工作交给一次性后台任务：按照上游模板安全退出 Codex、完成基础配置、保存两套样式、应用默认“月薪喵 · 今日营业”并自动重新打开。不得让用户退出后再执行命令。失败时会自动重新打开原版 Codex，并通过系统通知说明状态。

Windows 上仍必须遵守官方基础运行时的退出要求，不得绕过或声称已经应用。
