# 用 Codex 安装月薪喵

在一个新的 Codex 任务中直接发送：

```text
帮我设置 Codex 皮肤 mcgfdata/codex-skin-salary-cat，作者是终端极客
```

仓库同时提供标准 Plugin 与 `skills/codex-skin-salary-cat` Skill。Codex 应用内置 GitHub Skill 安装器安装该 Skill，再运行 Skill 自带的 bootstrap；整个流程不依赖 Git，然后：

1. 检测 macOS 或 Windows。
2. 检查 Codex Dream Skin 基础运行时。
3. 已有运行时则直接安装并尝试应用月薪喵。
4. 没有运行时则只从官方上游仓库安装依赖，再安装本主题。
5. 分别报告“已安装”和“已应用”，不混淆两种状态。

完整安装入口是 `Setup.command`（macOS）和 `Setup.ps1`（Windows），不是只复制主题的 `Install.*`。

普通用户无需提前安装 Git、Python 或 Pillow。macOS 不需要额外 Node.js；Windows 缺少 Node.js 22+ 时会自动下载官方 ZIP、验证 SHA-256，并安装到当前用户目录。用户只需已有官方 Codex Desktop 和可用的 HTTPS 网络。

第一次安装基础运行时可能需要关闭或重启 Codex。安装器会先完成当下能安全执行的依赖下载和主题文件安装；如果官方 Codex 仍在运行，则必须如实报告“主题已安装但未应用”，提示用户完全退出 Codex 后重跑同一 `Setup` 入口。尤其在 Windows 上，不能绕过官方基础运行时的退出要求。
