# 🎨 UI 风格规范：港汇通 (HK Hub)

> 版本 v1 · 2026-10-14
> 适用范围：`hkhub_app` 全部界面
> 唯一真相源：`lib/app/theme/`（全局骨架与色板）与 `lib/modules/<module>/theme/`（模块强调色）

---

## 1. 一句话原则

> **统一骨架，独立强调色。**

所有工具共用同一套「**结构语言**」（圆角、间距、字体层级、卡片配方、语义色、交互动效、图标风格）；每个工具只允许拥有自己的「**强调色**」。

不允许出现「每个工具一套完整设计」的情况——那会让 App 变成多个产品缝合在一起。

---

## 2. 三层色彩模型（核心）

整套色彩只有三个层级，**互不串用**。这是整机观感统一的地基。

| 层级 | 角色 | 取值 | 用在哪 | 可自定义？ |
| :--- | :--- | :--- | :--- | :--- |
| **L1 结构 / 品牌色** | 骨架与动作 | `AppTheme.ferryGreen`（主色，**青色为主**）+ `AppTheme.harborBlue`（结构锚点） | 品牌头、状态栏、主按钮、导航、链接 | ❌ 全局唯一 |
| **L2 分类色板**（中明度） | 分类编码 | `ToolAccents`（6 色受控色板） | 首页工具磁贴、分组标记、图表序列、标签 | ⚠️ 只能从色板取 |
| **L3 语义状态色** | 状态语义 | `AppTheme.levelLow / levelMedium / levelHigh / levelNeutral`、`signalAmber` | 拥堵等级、成功/警告/错误、风险提示 | ❌ 语义固定 |

**三条不可违反的规则：**

1. **L1 只用于「结构 + 动作」**，不用于分类。
2. **L2 只用于「分类编码」**，不用于状态。
3. **L3 只用于「状态语义」**，绝不作为品牌色或分类色。

> 判断口诀：**动作找 L1，分类找 L2，状态找 L3。** 拿不准时先问「这个颜色在表达什么」。

> **主色为 `ferryGreen`（青）**（青色为主）；`harborBlue`（深蓝）退为「结构锚点」，用于入场方向强调与深色表面。品牌头、状态栏、主按钮均已切青。

---

## 3. L2 分类色板（`ToolAccents`）

分类色全部锚定在**同一明度带（HSL 明度 ≈ 46%）**，饱和度控制在 40%–55%。这是任意两个颜色并排都不会「一个压一个」的唯一保证。

| 名称 | 值 | 明度 | 语义归属 |
| :--- | :--- | :--- | :--- |
| `jade` | `#3BB0A6` | 46% | 出行 / 跨境通勤 |
| `violet` | `#5A4E9E` | 46% | 身份 / 永居（沿用既有 plum） |
| `indigo` | `#3B62B0` | 46% | 教育 / 择校 |
| `amber` | `#B06C3B` | 46% | 商业 / 牌照数据 |
| `rose` | `#B03B62` | 46% | 提醒 / 风险类分类 |
| `olive` | `#7E9E3B` | 43% | 成长 / 进度 |

**约束：**

- 新增分类色**必须**保持在 L 40%–50% 区间，并追加到 `ToolAccents.palette` 末尾（顺序参与兜底哈希，改动会影响已有兜底色）。
- **禁止**在任何页面直接写 `Color(0xFF...)` 作为分类色——一律走 `ToolAccents`。
- `amber`（分类色）与 `signalAmber`（状态色）**是两回事**：前者表达「这是商业类工具」，后者表达「这里是警告」。

---

## 4. 分组编码规则（可扩展性关键）

> **颜色编码「分组」，不编码「单个工具」。**

工具数量会持续增长，若「一个工具一个颜色」，很快会穷尽可区分色、退化成彩虹。正确做法是：**同一分组的所有工具共用一个分类色**。

- 分组色由 `ToolAccents.forGroup(groupId)` 决定；
- 已明确归属的分组在 `ToolAccents._byGroup` 中显式登记；
- 未登记的分组走**稳定哈希兜底**，自动获得一个固定颜色——**新增工具只要归组，颜色自动到位，零维护**。

颜色因此成为**信息**（「这是一类工具」），而不是装饰。

---

## 5. 结构 Token（必须统一，不得重定义）

以下 token 由 `AppTheme` 统一定义，模块主题**只能继承，不得覆盖**。

### 5.1 圆角

| 用途 | 值 |
| :--- | :--- |
| 卡片 / 大面板 | `AppTheme.cardRadius` = 24 |
| 强调按钮 / 磁贴 | 18 |
| 输入框 / 次级按钮 | 14–16 |
| 默认按钮 | 12 |

### 5.2 间距

- 页面左右安全边距：**20**；
- 常规元素间距：**12 / 14 / 18**；
- 内容最大宽度：单列页面 **680**，列表/首页 **760**，品牌头 **800**；
- 卡片内边距：水平 16–18，垂直 14–18。

### 5.3 字体层级

| 层级 | 字号 / 字重 | 用在哪 |
| :--- | :--- | :--- |
| 品牌标题 | 25 / w700 | 首页品牌头 |
| 页面标题 | 18 / w700 | AppBar |
| 卡片主标题 | 21 / w700 | 强调卡片 |
| 磁贴标题 | 14 / w600 | 工具磁贴 |
| 正文 | 14 | 段落 |
| 辅助 | 13 | 副标题、说明 |
| 极小 | 10–12 | 标签、脚注 |

### 5.4 卡片配方

统一使用 `AppTheme.cardSurface()`（白底 + `surfaceLine` 描边 + `cardRadius` 圆角），或 `AppTheme.tinted(accent)`（强调色 6% 透明底）。

### 5.5 图标

- 风格：**线性图标**（Flutter `Icons.*_outlined`），不混用实心图标；
- 品牌符号：`HkSailMark`（代码绘制的帆船，见第 6 节）；
- 磁贴图标尺寸 34，容器 60×60、圆角 18、底色为分类色 10% 透明。

### 5.6 动效

- 页面滚动联动：220ms，`MediaQuery.disableAnimationsOf` 为真时降级为 0；
- 所有动效必须尊重系统「减弱动态效果」开关。

---

## 6. 品牌符号：帆船

品牌符号是 `HkSailMark`（`lib/app/widgets/hk_sail_mark.dart`），代码绘制、无图片资源，`size` 从 24 到全屏等比缩放。

| 形态 | 参数 | 用在哪 |
| :--- | :--- | :--- |
| **Logo（静态）** | `HkSailMark(animate: false)` | 品牌头、启动页、分享卡 |
| **Loading（动效）** | `HkSailMark(animate: true)` / `HkSailLoader()` | 所有加载态，替掉 `CircularProgressIndicator` |

- 颜色默认取 `Theme.colorScheme.primary`（品牌青），可传 `color` 覆盖；品牌头上用白色；
- 动效为「船身起伏 + 轻微横摇 + 水线漂移」，并自动尊重系统「减弱动态效果」开关；
- **禁止**再用 `CircularProgressIndicator` 作为页面级加载态——统一走帆船，让品牌符号长进交互里。

**平台图标**由 `tool/generate_icons.dart` 分发：工具**不绘制**图标，而是把外部母版 `assets/images/app_icon.png`（1024px 方形）**等比缩放**派发到全平台。换品牌 = 换这张 PNG 再重跑。

> **一个母版，全平台一致。** 启动器怎么裁剪（Pixel 圆形、三星/小米圆角方……）是启动器的事——品牌资产不为猜不到的蒙版做妥协，iOS 与 Android 的图标就是同一张图的不同分辨率。

| 产物 | 形式 |
| :--- | :--- |
| 母版（唯一来源） | `assets/images/app_icon.png` — 品牌青底 + 白帆船 + 波浪 |
| iOS 应用图标 | 母版缩放 × 15 张（不透明） |
| Android 应用图标 | 母版缩放 × 5 档密度（`res/mipmap-*/ic_launcher.png`） |
| Android 自适应图标 | 母版缩放 × 5 作前景层；背景层用同色纯色（`res/values/colors.xml`） |
| Android 启动屏 logo | 母版缩放 × 5（`res/drawable-*/launch_image.png`） |
| iOS 启动屏 logo | 母版缩放 × 3（`Assets.xcassets/LaunchImage.imageset/`） |

> 换了母版后，重跑 `./cmd.sh icons`（等价于 `flutter test tool/generate_icons.dart`）全平台同步；同时会导出 `build/icon_preview/launcher_masks.png`——母版在方形 / 圆角方 / 圆形蒙版下的样子，用于目视各启动器效果。

---

## 7. 目录约定与唯一真相源

```
lib/app/theme/
  app_theme.dart      # L1 结构/品牌色 + L3 语义色 + 卡片/圆角配方（全局唯一）
  tool_accents.dart   # L2 分类色板 + 分组编码（唯一分类色来源）

lib/app/widgets/
  hk_sail_mark.dart   # 品牌符号：帆船（App 内 logo 与 loading 共用一套绘制）

assets/images/
  app_icon.png        # 图标母版（外部设计资产，唯一来源，由 ./cmd.sh icons 分发）

lib/modules/<module>/theme/
  <module>_theme.dart # 仅定义「强调色相关」的局部 token，其余一律继承 AppTheme
```

**模块主题的合法职责：**

1. 从 `ToolAccents` 取自己的强调色；
2. 覆盖「强调色相关」的局部 token（按钮、选中态、焦点边框）；
3. 如有需要，定义自己的**浅底背景色**（可微调色调）作为「小世界」的氛围。

**模块主题禁止：**

- 重定义圆角、间距、字体层级、语义状态色；
- 引入 `ToolAccents` 之外的分类色；
- 把状态色当强调色用。

---

## 8. 新增工具 Checklist

- [ ] 在服务端 tool-catalog 归入某个**分组**（`group.id`）；
- [ ] 若该分组尚无分类色，在 `ToolAccents._byGroup` 登记一个色板色；不登记则自动兜底；
- [ ] 页面若需要独立强调色，从 `ToolAccents` 取，**不写死 hex**；
- [ ] 至少通过一处校验（`flutter analyze` 无 warning、`flutter test` 通过）；
- [ ] 自检：小尺寸可辨、灰阶可辨、深浅色下对比度达标。

---

## 9. 禁止事项（红线）

1. ❌ 在页面/组件里硬编码 `Color(0xFF...)` 作为强调色或分类色；
2. ❌ 一个模块出现两个及以上强调色；
3. ❌ 把 L3 语义色（如 `signalAmber`）当作品牌色或分类色；
4. ❌ 模块主题重定义圆角 / 间距 / 字体 / 语义色；
5. ❌ 混用线性与实心图标风格；
6. ❌ 新增分类色超出 L 40%–50% 明度带。

---

## 10. 迁移状态

| 项 | 状态 | 说明 |
| :--- | :--- | :--- |
| 三层色彩模型定义 | ✅ 已完成 | 见第 2 节 |
| `ToolAccents` 分类色板 | ✅ 已完成 | `lib/app/theme/tool_accents.dart` |
| 首页工具磁贴改为「按分组给色」 | ✅ 已完成 | `tool_grid.dart` |
| 模块强调色接入分类色板 | ✅ 已完成 | education / residency / commute |
| 全局主色切换为 `ferryGreen`（青为主） | ✅ 已完成 | `AppTheme.light` + 品牌头/状态栏 + 通勤模块跟随 |
| 帆船品牌符号：logo + loading 统一 | ✅ 已完成 | `HkSailMark` / `HkSailLoader`，已替掉各页 `CircularProgressIndicator` |
| App 图标改为帆船（母版分发） | ✅ 已完成 | `tool/generate_icons.dart` 把 `assets/images/app_icon.png` 等比缩放派发到 Android 5 档 + 自适应 + iOS 15 张 + 两端启动屏，见第 6 节 |
