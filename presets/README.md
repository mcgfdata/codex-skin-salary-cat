# 预设主题

这里放月薪喵的主体皮肤预设包。
当前仓库保留两个可切换布局：

- `preset-yuexinmiao-payday`：默认今日营业横幅，保留完整横向构图，任务页使用 `banner`
- `preset-yuexinmiao`：沉浸布局，聚焦右侧主体，任务页使用 `ambient`

两套预设都只基于 `source/salary-cat-source.png` 生成，不额外引入新画面。源图约为 `2.40:1`：默认布局转成 `16:9` 时主要裁掉左侧留白；今日营业布局按完整宽度缩放到 `1.40:1` 同色画布底部，使其低于 Dream Skin 的 `1.45` 宽图扩展阈值并保留首页横幅卡片。两者都不会增加源图细节。

生成后结构如下：

```text
preset-yuexinmiao/
├── background.jpg
└── theme.json

preset-yuexinmiao-payday/
├── background.jpg
└── theme.json
```

设置时，脚本会把两个目录一起复制到 Codex Dream Skin 的本机主题库；默认应用 `preset-yuexinmiao-payday`，用户可在“已保存的主题”中切换：

- macOS: `~/Library/Application Support/CodexDreamSkinStudio/themes/`
- Windows: `%LOCALAPPDATA%\CodexDreamSkin\themes/`

重新生成后运行：

```bash
python3 scripts/validate_theme.py
```

主题配色同时使用素材里的耳机蓝、植物绿、金币黄和轮廓暖棕，避免整个界面只剩米棕色。
