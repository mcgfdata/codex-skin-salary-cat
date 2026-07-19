# 预设主题

这里放月薪喵的主体皮肤预设包。
当前仓库只保留一个 preset：

- `preset-yuexinmiao`

这套预设只基于 `source/salary-cat-source.png` 做 cover 裁切，不额外引入新画面。源图约为 `2.40:1`，转成 `16:9` 时会主要裁掉左侧留白，并放大有效画面；生成结果不会增加源图细节。

生成后结构如下：

```text
preset-yuexinmiao/
├── background.jpg
└── theme.json
```

安装时，脚本会把这个目录复制到 Codex Dream Skin 的本机主题库：

- macOS: `~/Library/Application Support/CodexDreamSkinStudio/themes/`
- Windows: `%LOCALAPPDATA%\CodexDreamSkin\themes/`

重新生成后运行：

```bash
python3 scripts/validate_theme.py
```

主题配色同时使用素材里的耳机蓝、植物绿、金币黄和轮廓暖棕，避免整个界面只剩米棕色。
