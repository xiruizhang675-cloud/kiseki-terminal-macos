<p align="center">
  <img src="./assets/banner.svg" alt="Kiseki Terminal for macOS — Anime Theme Collection for Ghostty & Zsh" width="100%" />
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-66f0ff?style=flat-square" alt="License: MIT" /></a>
  <img src="https://img.shields.io/badge/Platform-macOS-ff82b8?style=flat-square" alt="macOS" />
  <img src="https://img.shields.io/badge/Terminal-Ghostty_1.2%2B-7aa2f7?style=flat-square" alt="Ghostty 1.2+" />
  <img src="https://img.shields.io/badge/Shell-Zsh_%2B_Oh_My_Zsh-b48efe?style=flat-square" alt="Zsh + Oh My Zsh" />
</p>

> **Kiseki Terminal (macOS Edition)** — 将 [nerv-base/kiseki-terminal](https://github.com/nerv-base/kiseki-terminal) 原生移植到 **macOS + Ghostty + Zsh / Oh My Zsh + Oh My Posh + Fastfetch** 的二次元终端美化套件。  
> 完整复用原项目的 4 套专属构图壁纸、16 色 ANSI 配色、Oh My Posh 提示符、Fastfetch 真彩半块像素徽章，并新增 **Ghostty 原生 GLSL CRT 着色器**、**Zsh 热切换引擎** 与 **Oh My Zsh / Powerlevel10k 零冲突一键安装卸载器**。

---

## Gallery / 主题预览

### 1. `starlight-8bit` — 星屑 8-Bit（复古像素夜空）
> PC-98 / GBA 像素风 · 深靛夜空 `#0A0F25` + 街机霓虹青 + 樱花粉 · RPG 抖动渐变 HUD (`░▒▓ ... ▓▒░` / `♥ ▶`)

![Starlight 8-Bit Preview](./previews/starlight-8bit.png)

### 2. `nerv-eva` — NERV UNIT-02（特务机关 弐号机战术蓝图）
> 曜石暗黑 `#0B090A` + 弐号机装甲绯红 `#D8262E` + 战术橙标 `#F06A22` + 同步率荧光绿 `#3FE08A` · `▛ 02 ▟` / `┗━[弐号機] ▸`

![NERV UNIT-02 Preview](./previews/nerv-eva.png)

### 3. `shinkai-rain` — 言叶之雨（新海诚东京雨夜）
> 靛青雨幕 `#0C1823` + 霓虹水青 + 便利店暖金散景 · 极简玻璃雨滴弧线提示符 (`╭─ ☂ ...` / `╰─ ❯`)

![Shinkai Rain Preview](./previews/shinkai-rain.png)

### 4. `kyoto-sakura` — 夜樱绘卷（和风月夜神社）
> 墨紫夜空 `#0F0B19` + 月下垂枝樱粉 + 石灯笼暖金 + 朱红鸟居 · 日式直角引号印章提示符 (`「 ✿ ... 」` / `❀ ›`)

![Kyoto Sakura Preview](./previews/kyoto-sakura.png)

---

## Features / 核心特性

- **原生 Ghostty 适配**：通过 `config-file` 模块化挂载，零破坏保留你的原有 Ghostty 快捷键、Quick Terminal 与滚动配置；支持 `background-image-position = bottom-right` + `cover` 等比锚定。
- **GLSL CRT 着色器**：将原版 HLSL 复古 CRT 荧光辉光 + 2px 微扫描线完整移植为 Ghostty 原生 Shadertoy GLSL（`shaders/retro-crt-subtle.glsl`），`crt` 一键开关，文字 100% 锐利。
- **与 Oh My Zsh 和平共处**：仅接管提示符层（自动将 `ZSH_THEME` 留空，并安全注释 Powerlevel10k 相关行），在 `source "$ZSH/oh-my-zsh.sh"` **之后**加载提示符、`eza`/`bat` 别名与 `fastfetch`，完整保留你的 OMZ 插件与自动补全。
- **全链路色彩统一**：一套主题同步切换 Ghostty 16 色、壁纸、光标、Oh My Posh、Fastfetch、`eza` 文件树、`bat` 语法高亮与 `fzf` 配色。
- **自动备份 & 一键卸载**：安装前自动备份 `~/.zshrc` 与 Ghostty 配置到 `~/.config/kiseki-backup-*`，随时可 `./install.sh --uninstall` 干净还原。

---

## Quick Install / 快速安装

### 环境要求
- **macOS** + [Ghostty](https://ghostty.org/) `1.2+`
- [Homebrew](https://brew.sh/)（用于自动安装 `oh-my-posh`、`fastfetch`、`eza`、`bat`）
- 推荐安装 Nerd Font（如 `Maple Mono NF CN`、`JetBrainsMono Nerd Font`，或像素风 `DepartureMono Nerd Font`）以正常显示图标：
  ```zsh
  brew install --cask font-maple-mono-nf-cn
  # 可选：为 starlight-8bit 安装 8-bit 像素英文字体
  brew install --cask font-departure-mono-nerd-font
  ```

### 本地安装（推荐）
```zsh
git clone https://github.com/xiruizhang675-cloud/kiseki-terminal-macos.git
cd kiseki-terminal-macos
./install.sh
```

### 一行命令远程安装
```zsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xiruizhang675-cloud/kiseki-terminal-macos/main/install.sh)"
```

### 安装选项
| 参数 | 说明 |
| :--- | :--- |
| `--theme <id>` | 指定默认主题：`starlight-8bit`（默认）/ `nerv-eva` / `shinkai-rain` / `kyoto-sakura` |
| `--crt` | 默认开启复古 CRT GLSL 着色器 |
| `--skip-tools` | 跳过 Homebrew 安装 `oh-my-posh` / `fastfetch` / `eza` / `bat` |
| `--uninstall` | 卸载 Kiseki Terminal 并还原 `~/.zshrc` 与 Ghostty 配置 |

安装完成后，在 Ghostty 中按 `Cmd + Shift + ,` 热重载配置，并执行 `exec zsh` 即可生效。

---

## Commands / 日常热切换命令

| 命令 | 说明 |
| :--- | :--- |
| `themes` | 查看 4 套主题与当前激活状态 / CRT 状态 |
| `theme <id>` | 一键热切换主题（支持 Tab 补全：`starlight-8bit` / `nerv-eva` / `shinkai-rain` / `kyoto-sakura`） |
| `crt` / `crt on` / `crt off` | 开/关复古 CRT 荧光辉光 + 2px 扫描线 GLSL 着色器 |
| `termbg 0.35` / `termbg off` / `termbg reset` | 调整壁纸透明度、关闭壁纸或恢复主题默认值 |
| `termfont maple \| modern \| 8bit \| reset` | 单独切换字体栈或恢复默认 |
| `fetch` | 重新展示当前主题的 Fastfetch 像素徽章（设 `NO_FETCH=1` 可跳过启动展示） |
| `ls` / `ll` / `la` / `lt` / `cat` | 自动映射为随主题变色的 `eza` 与 `bat` |

---

## Credits & License / 致谢与许可

- 原项目与全部二次元壁纸、16 色方案、Oh My Posh 提示符、Fastfetch 像素徽章及 HLSL CRT 着色器设计源自 **[nerv-base/kiseki-terminal](https://github.com/nerv-base/kiseki-terminal)**（MIT License）。
- 字体与工具：[Maple Mono NF CN](https://github.com/subframe7536/maple-font) · [Departure Mono](https://github.com/rektdeckard/departure-mono) · [Fusion Pixel Font](https://github.com/TakWolf/fusion-pixel-font) · [Ghostty](https://ghostty.org) · [Oh My Posh](https://ohmyposh.dev) · [Fastfetch](https://github.com/fastfetch-cli/fastfetch) · [eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat)
- 本仓库延续原项目的 **MIT License**，详见 [LICENSE](./LICENSE)。
