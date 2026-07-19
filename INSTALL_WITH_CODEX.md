# 用 Codex 安装月薪喵

在一个新的 Codex 任务中直接发送：

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

仓库同时提供标准 Plugin 与 `skills/codex-skin-salary-cat` Skill。Codex 应先获取仓库或用内置 GitHub Skill 安装器安装该 Skill，然后：

1. 检测 macOS 或 Windows。
2. 检查 Codex Dream Skin 基础运行时。
3. 已有运行时则直接安装并尝试应用月薪喵。
4. 没有运行时则只从官方上游仓库安装依赖，再安装本主题。
5. 分别报告“已安装”和“已应用”，不混淆两种状态。

完整安装入口是 `Setup.command`（macOS）和 `Setup.ps1`（Windows），不是只复制主题的 `Install.*`。

第一次安装基础运行时可能需要关闭或重启 Codex。尤其在 Windows 上，基础运行时安装器要求先退出官方 Codex；这种情况下当前任务会帮助准备安装，但必须如实提示用户完成关闭/重启步骤。
