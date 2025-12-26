# 神话生物图鉴 App - 项目需求文档

## 一、项目概述

### 1.1 产品名称
- 中文名：神兽志
- 英文名：Mythical Bestiary

### 1.2 产品定位
一款聚焦全球神话生物的图鉴类工具 App，提供神兽浏览、传说解读、文化故事、AI 生成专属神兽等功能。面向奇幻游戏玩家、神话爱好者、DND/TRPG 玩家、设计师等小众但高粘性用户群体。

### 1.3 核心卖点
- 视觉冲击力强：神话生物色彩鲜艳夸张（火焰红、雷电紫、冰霜蓝），形象奇幻震撼
- 内容有深度：每个生物背后都有神话传说和文化象征
- 跨文化融合：覆盖中国、希腊、北欧、日本、印度等多文化体系
- 互动性强：支持 AI 生成专属神兽、属性测试、神兽融合

### 1.4 技术方案
- **纯前端项目**，无后端服务（生成器可选集成 AI API）
- 数据本地 JSON 文件存储
- 用户数据使用本地存储（LocalStorage / 首选项）
- AI 图片生成：预置图库 + 可选 API 调用（Stable Diffusion / DALL-E）
- 目标平台：鸿蒙 HarmonyOS

---

## 二、功能模块

### 2.1 首页 - 发现

#### 2.1.1 轮播推荐
- 每日精选神兽（配 AI 生成高清大图 + 简短传说）
- 专题推荐（如"龙族图谱"、"北欧九界生物"、"山海经异兽"）

#### 2.1.2 快速入口
- 文化分类（中国/希腊/北欧/日本/印度/埃及/凯尔特）
- 属性分类（火/水/风/雷/光/暗/自然）
- 类型分类（龙族/神鸟/魔兽/精灵/不死生物）
- 我的收藏

#### 2.1.3 搜索
- 支持按名称、文化、属性、能力搜索
- 热门搜索词推荐（如"凤凰"、"九尾狐"、"独角兽"）
- 纯本地搜索，过滤 JSON 数据

---

### 2.2 图鉴浏览

#### 2.2.1 分类体系

```
├── 按文化体系
│   ├── 中国神话（龙、凤凰、麒麟、饕餮、九尾狐、鲲鹏...）
│   ├── 希腊神话（独角兽、狮鹫、美杜莎、米诺陶、百头龙...）
│   ├── 北欧神话（芬里尔、耶梦加得、瓦尔基里、冰霜巨人...）
│   ├── 日本神话（天照、八岐大蛇、九尾狐、天狗、河童...）
│   ├── 印度神话（迦楼罗、那伽、阿修罗、哈努曼...）
│   ├── 埃及神话（阿努比斯、荷鲁斯、斯芬克斯、巴斯特...）
│   └── 凯尔特神话（德鲁伊、女妖、班希、猎犬库兰...）
│
├── 按生物类型
│   ├── 龙族（东方龙、西方龙、羽蛇神、烛龙...）
│   ├── 神鸟（凤凰、朱雀、金翅鸟、雷鸟...）
│   ├── 魔兽（麒麟、白泽、狻猊、穷奇...）
│   ├── 精灵族（森林精灵、水精灵、暗夜精灵...）
│   ├── 巨人族（泰坦、山丘巨人、冰霜巨人...）
│   └── 不死生物（凤凰、不死鸟、僵尸龙...）
│
├── 按属性元素
│   ├── 火属性（火凤凰、炎龙、地狱犬、火巨人...）
│   ├── 水属性（水龙、海妖、克拉肯、水母精...）
│   ├── 风属性（风神翼龙、雷鸟、风精灵...）
│   ├── 雷属性（雷兽、麒麟、雷鸟、因陀罗...）
│   ├── 光属性（独角兽、圣龙、天马、光精灵...）
│   ├── 暗属性（地狱三头犬、夜魔、暗影龙...）
│   └── 自然属性（世界树、自然之灵、鹿神...）
│
└── 按善恶阵营
    ├── 守护神兽（麒麟、白虎、狮鹫、守护天使...）
    ├── 中立生物（龙族、精灵族、元素生物...）
    └── 灾厄魔兽（饕餮、穷奇、九婴、魔龙...）
```

#### 2.2.2 列表页
- 瀑布流/网格布局展示神兽缩略图
- 显示神兽名称、所属文化、属性图标
- 支持多维度筛选和排序

#### 2.2.3 详情页
- AI 生成高清神兽大图（支持缩放手势）
- 基本信息卡片：
  - 名称（原文 + 中文 + 英文）
  - 所属文化体系
  - 属性类型（火/水/风/雷等）
  - 阵营（守护/中立/灾厄）
  - 稀有度（传说/史诗/稀有/普通）
- 神话传说：完整的神话故事
- 能力特征：特殊能力、战斗技能、天赋
- 象征意义：文化象征、精神寓意
- 著名传说：知名的神话事件
- 相关生物推荐（同文化/同属性/同类型）

---

### 2.3 神话百科

#### 2.3.1 属性元素图鉴
每个属性元素单独成页，展示：
- 属性名称（中英文）
- 属性图标及配色（火-红、水-蓝、风-青、雷-紫、光-金、暗-黑）
- 象征含义
- 代表生物列表
- 属性相克关系图

#### 2.3.2 文化体系介绍
每个神话体系单独成页：
- 文化背景介绍
- 神话宇宙观（如北欧九界、希腊奥林匹斯）
- 代表性神兽
- 文化特色

#### 2.3.3 能力词典
神话生物常见能力中英对照 + 说明：
- 元素操控（火焰吐息、寒冰风暴、闪电链...）
- 物理能力（飞行、变形、再生、不死...）
- 精神能力（心灵感应、预知、诅咒...）
- 特殊天赋（守护、祝福、召唤...）

---

### 2.4 神兽生成器（核心互动功能）

#### 2.4.1 生成流程

**方式一：AI 自动生成**

**Step 1: 选择基础模板**
- 选择神话体系（中国/希腊/北欧/日本/混合）
- 选择生物类型（龙族/神鸟/魔兽/精灵/巨人）

**Step 2: 定义属性**
- 选择主属性（火/水/风/雷/光/暗/自然）
- 选择副属性（可选）
- 选择阵营（守护/中立/灾厄）

**Step 3: 外观特征**
- 选择配色方案（烈焰红、冰霜蓝、雷霆紫、圣光金...）
- 选择关键特征（翅膀/鳞片/角/尾/多头/元素特效...）

**Step 4: AI 生成**
- 使用 Stable Diffusion / DALL-E API 生成图片
- 提示词自动构建：文化风格 + 生物类型 + 属性 + 特征
- 示例提示词：`"Chinese mythology fire phoenix, red and gold feathers, majestic wings with flame effects, epic fantasy art, vibrant colors, high detail"`

**Step 5: 命名与保存**
- AI 自动生成神话风格名称（可修改）
- 自动生成简短传说故事
- 保存到「我的神兽」

**方式二：元素拼接生成（离线版）**

- 选择身体基座（龙躯/狮躯/鹰躯/人形...）
- 添加头部（龙头/狮头/鹰头/狼头/多头...）
- 添加翅膀（蝙蝠翼/羽翼/龙翼/骨翼...）
- 添加尾部（龙尾/蛇尾/狮尾/火焰尾...）
- 添加装饰（角/鳞片/羽毛/元素光效...）
- 选择配色（使用预设神话配色）
- 图层合成导出

#### 2.4.2 素材库（离线拼接方案）
- 身体基座 SVG（15+ 种）
- 头部元素 SVG（20+ 种）
- 翅膀元素 SVG（15+ 种）
- 尾部元素 SVG（10+ 种）
- 装饰元素 SVG（角/鳞片/羽毛/火焰特效等 20+）

#### 2.4.3 技术实现
**AI 生成方案**：
- 集成 Stable Diffusion API 或 DALL-E API
- 本地提示词模板库
- 图片缓存到本地

**离线拼接方案**：
- 使用 Canvas 或 SVG 渲染
- 图层叠加合成
- 导出为 PNG 保存到相册

---

### 2.5 专题故事

#### 2.5.1 图文专题
静态图文内容，预置在 App 内：
- 《世界十大神龙图谱》
- 《凤凰与不死鸟的异同》
- 《北欧诸神黄昏的魔兽军团》
- 《山海经异兽志》
- 《东西方龙文化对比》

#### 2.5.2 神话事件时间线
- 希腊神话泰坦之战
- 北欧诸神黄昏
- 中国上古神兽大战
- 配合事件节点展示相关神兽

---

### 2.6 互动娱乐

#### 2.6.1 每日神兽占卜
- 随机抽取一只神兽
- 显示该神兽象征的今日运势
- 分享功能

#### 2.6.2 属性测试
- 问答测试，判断用户的神话属性
- 推荐对应属性的守护神兽

#### 2.6.3 神兽战力对比
- 选择两只神兽进行属性对比
- 显示属性相克关系
- 娱乐向战力分析

---

### 2.7 我的（本地功能）

- **我的收藏**：收藏的神兽列表（本地存储）
- **我的神兽**：生成器创建的神兽（本地存储）
- **浏览历史**：最近浏览记录（本地存储）
- **设置**：主题切换（深色/浅色）、AI 生成开关、清除缓存
- **关于**：版本信息、内容来源说明、AI 模型说明

---

## 三、数据结构设计

### 3.1 神兽数据（creatures.json）

```typescript
interface MythicalCreature {
  id: string;
  name: {
    original: string;      // 原文名称
    cn: string;            // 中文名称
    en: string;            // 英文名称
  };
  culture: 'chinese' | 'greek' | 'norse' | 'japanese' | 'indian' | 'egyptian' | 'celtic' | 'mixed';
  type: 'dragon' | 'phoenix' | 'beast' | 'elf' | 'giant' | 'undead' | 'spirit' | 'hybrid';
  attributes: {
    primary: 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';
    secondary?: 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';
  };
  alignment: 'guardian' | 'neutral' | 'evil';
  rarity: 'legendary' | 'epic' | 'rare' | 'common';
  description: string;     // 中文通俗描述
  mythology: string;       // 神话传说完整故事
  abilities: string[];     // 能力 ID 列表
  symbolism: string;       // 象征意义
  famous_stories: {
    title: string;
    description: string;
  }[];
  appearance: {
    body_parts: string[];  // 身体部位描述
    colors: string[];      // 主要颜色
    features: string[];    // 关键特征
  };
  image: string;           // 图片文件名
  related: string[];       // 相关神兽 ID
  tags: string[];          // 标签，用于搜索
}
```

### 3.2 能力数据（abilities.json）

```typescript
interface Ability {
  id: string;
  name_cn: string;
  name_en: string;
  category: 'elemental' | 'physical' | 'mental' | 'special';
  description: string;
  attribute?: 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';
  famous_usage: {
    creature_id: string;
    description: string;
  }[];
}
```

### 3.3 属性数据（attributes.json）

```typescript
interface Attribute {
  id: 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';
  name_cn: string;
  name_en: string;
  color: string;          // 代表色
  symbol: string;         // 符号/图标
  meaning: string;        // 象征含义
  strengths: string[];    // 克制的属性
  weaknesses: string[];   // 被克制的属性
  representative_creatures: string[]; // 代表生物 ID
}
```

### 3.4 文化体系数据（cultures.json）

```typescript
interface CultureSystem {
  id: string;
  name_cn: string;
  name_en: string;
  region: string;         // 地理区域
  background: string;     // 文化背景介绍
  cosmology: string;      // 宇宙观/世界观
  features: string[];     // 文化特色
  representative_creatures: string[]; // 代表生物 ID
}
```

### 3.5 本地存储数据

```typescript
// 收藏列表
interface Favorites {
  creature_ids: string[];
}

// 用户创建的神兽
interface UserCreature {
  id: string;
  name: string;
  config: {
    // AI 生成方案
    generation_type: 'ai' | 'manual';
    culture?: string;
    type?: string;
    primary_attribute?: string;
    secondary_attribute?: string;
    alignment?: string;
    color_scheme?: string;
    features?: string[];
    prompt?: string;        // AI 提示词

    // 手动拼接方案
    body?: string;
    head?: string;
    wings?: string;
    tail?: string;
    decorations?: string[];
    colors?: Record<string, string>;
  };
  story?: string;          // 用户自定义传说
  image_base64: string;    // 保存为 base64
  created_at: number;
}

// 浏览历史
interface History {
  items: {
    creature_id: string;
    timestamp: number;
  }[];
}
```

---

## 四、页面设计要求

### 4.1 整体风格
- **主色调**：深蓝紫渐变 #1a1a3e → #2d1b4e（神秘奇幻感）
- **强调色**：金色 #ffd700（传说品质）、紫色 #9d4edd（史诗品质）、蓝色 #4cc9f0（稀有品质）
- **背景**：深色星空主题，突出神兽鲜艳色彩
- **装饰**：流光特效、粒子效果、神话纹样边框
- **字体**：标题使用有力度的字体，正文清晰易读

### 4.2 神话配色方案

| 属性 | 主色 | 辅色 | 特效色 |
|------|------|------|--------|
| 火 | #ff4500 | #ff8c00 | #ffff00（火焰） |
| 水 | #1e90ff | #00ced1 | #afeeee（水纹） |
| 风 | #7fffd4 | #98fb98 | #f0ffff（气流） |
| 雷 | #9370db | #8a2be2 | #ffffff（闪电） |
| 光 | #ffd700 | #ffffe0 | #fffacd（圣光） |
| 暗 | #2f4f4f | #191970 | #8b008b（暗影） |
| 自然 | #228b22 | #3cb371 | #90ee90（生机） |

### 4.3 关键页面

#### 首页
```
┌─────────────────────────┐
│  ✦ 神话图鉴 ✦    [搜索] │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │   AI 生成神兽大图  │  │
│  │   今日精选: 烛龙   │  │
│  └───────────────────┘  │
├─────────────────────────┤
│  [中国🐉][希腊🦅][北欧⚡][日本🦊]│
│  [火🔥][水💧][风🌪][雷⚡]│
├─────────────────────────┤
│  传说神兽               │
│  ┌───┐ ┌───┐ ┌───┐     │
│  │凤凰│ │龙 │ │麒麟│    │
│  └───┘ └───┘ └───┘     │
├─────────────────────────┤
│  专题推荐               │
│  ┌─────────────────┐    │
│  │ 世界龙族图谱      │    │
│  └─────────────────┘    │
├─────────────────────────┤
│  [首页] [图鉴] [生成] [我的]│
└─────────────────────────┘
```

#### 详情页
```
┌─────────────────────────┐
│  [返回]          [收藏❤]│
├─────────────────────────┤
│      ┌─────────┐        │
│      │         │        │
│      │ AI神兽  │        │
│      │  大图   │        │
│      │         │        │
│      └─────────┘        │
├─────────────────────────┤
│  烛龙 Torch Dragon      │
│  🏮 中国神话 · 🔥火属性  │
│  ⭐ 传说级 · 守护阵营    │
├─────────────────────────┤
│  [神话] [能力] [象征] [故事]│
├─────────────────────────┤
│  人面龙身，口衔烛火，     │
│  睁眼为昼，闭眼为夜...   │
├─────────────────────────┤
│  🔥 能力: 昼夜掌控、火焰 │
│  相关神兽               │
│  ┌───┐ ┌───┐ ┌───┐     │
└─────────────────────────┘
```

#### AI 生成器页
```
┌─────────────────────────┐
│  [返回]   神兽生成器     │
├─────────────────────────┤
│      ┌─────────┐        │
│      │         │        │
│      │ AI预览  │        │
│      │         │        │
│      └─────────┘        │
├─────────────────────────┤
│  神话体系: 中国 ▼        │
│  生物类型: 龙族 ▼        │
│  主属性:   🔥火 ▼        │
│  阵营:     守护 ▼        │
├─────────────────────────┤
│  配色方案:              │
│  ● 烈焰红金             │
│  ○ 冰霜蓝白             │
│  ○ 雷霆紫银             │
├─────────────────────────┤
│  关键特征:              │
│  ☑ 龙翼 ☑ 火焰 □ 多头  │
├─────────────────────────┤
│       [AI 生成神兽]      │
│       [保存到我的]       │
└─────────────────────────┘
```

---

## 五、目录结构建议（HarmonyOS ArkTS）

```
entry/src/main/
├── ets/
│   ├── pages/
│   │   ├── Index.ets              // 首页
│   │   ├── CreatureList.ets       // 神兽列表
│   │   ├── CreatureDetail.ets     // 神兽详情
│   │   ├── AbilityList.ets        // 能力百科
│   │   ├── CultureList.ets        // 文化体系列表
│   │   ├── Generator.ets          // AI 生成器
│   │   ├── Topic.ets              // 专题文章
│   │   ├── Search.ets             // 搜索页
│   │   ├── DailyDivination.ets    // 每日占卜
│   │   └── Mine.ets               // 我的页面
│   │
│   ├── components/
│   │   ├── CreatureCard.ets       // 神兽卡片组件
│   │   ├── Banner.ets             // 轮播组件
│   │   ├── AttributeTag.ets       // 属性标签
│   │   ├── SearchBar.ets          // 搜索栏
│   │   ├── AIGeneratorCanvas.ets  // AI 生成器画布
│   │   └── AttributeCircle.ets    // 属性相克关系图
│   │
│   ├── model/
│   │   ├── MythicalCreature.ets   // 神兽数据模型
│   │   ├── Ability.ets            // 能力数据模型
│   │   ├── Attribute.ets          // 属性数据模型
│   │   └── UserData.ets           // 用户数据模型
│   │
│   ├── utils/
│   │   ├── DataLoader.ets         // JSON 数据加载
│   │   ├── Storage.ets            // 本地存储封装
│   │   ├── AIGenerator.ets        // AI 图片生成（API 调用）
│   │   ├── PromptBuilder.ets      // AI 提示词构建
│   │   ├── ImageExport.ets        // 图片导出工具
│   │   └── Search.ets             // 搜索工具
│   │
│   └── common/
│       ├── Constants.ets          // 常量定义
│       ├── Theme.ets              // 主题配置
│       └── AttributeColors.ets    // 属性配色方案
│
└── resources/
    └── rawfile/
        ├── data/
        │   ├── creatures.json     // 神兽数据
        │   ├── abilities.json     // 能力数据
        │   ├── attributes.json    // 属性数据
        │   ├── cultures.json      // 文化体系数据
        │   └── topics.json        // 专题数据
        │
        ├── images/
        │   ├── creatures/         // AI 生成的神兽图片
        │   ├── attributes/        // 属性图标
        │   └── cultures/          // 文化体系图标
        │
        ├── svg/                   // 手动拼接素材（可选）
        │   ├── bodies/            // 身体基座
        │   ├── heads/             // 头部元素
        │   ├── wings/             // 翅膀元素
        │   ├── tails/             // 尾部元素
        │   └── decorations/       // 装饰元素
        │
        └── prompts/
            └── templates.json     // AI 提示词模板库
```

---

## 六、开发计划

### Phase 1 - MVP（2-3 周）
- [ ] 项目初始化 & 基础架构
- [ ] 首页布局 + 轮播
- [ ] 神兽列表页（按文化分类）
- [ ] 神兽详情页
- [ ] 本地搜索功能
- [ ] 收藏功能（本地存储）
- [ ] 准备初始数据（50+ 神兽）
- [ ] AI 生成图片（预置 or API）

### Phase 2 - 完善（2 周）
- [ ] 神话百科模块（属性/文化/能力）
- [ ] 更多分类维度（属性/类型/阵营）
- [ ] 浏览历史
- [ ] 专题文章页面
- [ ] 每日占卜功能
- [ ] 属性测试
- [ ] 深色/浅色主题切换

### Phase 3 - 生成器（2-3 周）
- [ ] AI 生成器 UI
- [ ] 集成 Stable Diffusion / DALL-E API
- [ ] 提示词模板库
- [ ] 手动拼接方案（备选）
- [ ] 图片缓存与导出
- [ ] 生成历史管理

---

## 七、数据准备清单

### 7.1 首批内容（50-80 个神兽）

**中国神话（15-20）**：
- 龙族：应龙、烛龙、螭龙、虬龙
- 神鸟：凤凰、朱雀、鲲鹏、毕方
- 四灵：青龙、白虎、朱雀、玄武
- 瑞兽：麒麟、白泽、獬豸
- 凶兽：饕餮、穷奇、梼杌、浑沌、九婴

**希腊神话（15）**：
- 独角兽、飞马、狮鹫、百头龙、九头蛇
- 美杜莎、米诺陶、半人马、斯芬克斯、珀伽索斯

**北欧神话（10）**：
- 芬里尔、耶梦加得、斯莱普尼尔、尼德霍格
- 冰霜巨人、火焰巨人、瓦尔基里

**日本神话（10）**：
- 九尾狐、八岐大蛇、天狗、河童、座敷童子
- 雪女、酒吞童子、大天狗

**印度神话（8）**：
- 迦楼罗、那伽、阿修罗、哈努曼、湿婆神牛

**埃及神话（8）**：
- 阿努比斯、荷鲁斯、塞赫美特、斯芬克斯、阿佩普

**凯尔特神话（5）**：
- 女妖、班希、猎犬库兰、仙女

### 7.2 图片准备方案

**方案一：AI 批量生成（推荐）**
- 使用 Midjourney / Stable Diffusion 批量生成
- 提示词模板：`"{神兽名} from {文化} mythology, {属性} element, {特征描述}, epic fantasy art, vibrant {颜色}, cinematic lighting, high detail, 4K"`
- 图片规格：1024x1024 PNG
- 后期精修和风格统一

**方案二：素材收集 + AI 辅助**
- 从公共领域收集基础素材
- 使用 AI 图片增强和风格转换
- 统一视觉风格

### 7.3 AI 提示词模板库

```json
{
  "templates": {
    "dragon": "{culture} mythology dragon, {attribute} element, {color_scheme}, majestic wings, detailed scales, {special_features}, epic fantasy art, vibrant colors, cinematic lighting",
    "phoenix": "{culture} mythology phoenix, {attribute} element, {color_scheme}, magnificent tail feathers, flame effects, {special_features}, fantasy art, glowing effects",
    "beast": "{culture} mythology {beast_type}, {attribute} element, {color_scheme}, powerful body, {special_features}, epic creature design, detailed fur/scales"
  }
}
```

### 7.4 内容来源
- Wikipedia 神话生物条目
- 古代神话典籍（山海经、希腊神话全集、北欧埃达等）
- AI 生成图片（Midjourney / Stable Diffusion）
- 公共领域神话插画

---

## 八、AI 生成技术方案

### 8.1 方案对比

| 方案 | 优点 | 缺点 | 成本 |
|------|------|------|------|
| 预生成打包 | 无需联网、加载快、质量可控 | 包体积大、内容固定 | 一次性成本 |
| API 实时生成 | 无限可能、包体积小、持续更新 | 需联网、有延迟、质量不稳定 | 按调用计费 |
| 混合方案 | 平衡体验与成本 | 实现复杂度高 | 中等 |

### 8.2 推荐方案：预生成 + 可选 API

**基础版（MVP）**：
- 预置 50-80 个 AI 生成的高质量神兽
- 生成器使用手动拼接方案（SVG 素材）

**完整版**：
- 基础图鉴预置
- 生成器集成 Stable Diffusion API
- 用户设置可开关 AI 生成功能

### 8.3 API 集成建议

**Stable Diffusion API**（推荐）：
```typescript
async function generateCreature(config: GeneratorConfig): Promise<string> {
  const prompt = buildPrompt(config);
  const response = await fetch('https://api.stability.ai/v1/generation', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY'
    },
    body: JSON.stringify({
      prompt: prompt,
      width: 1024,
      height: 1024,
      samples: 1
    })
  });
  const data = await response.json();
  return data.artifacts[0].base64; // 返回 base64 图片
}
```

---

## 九、项目检查清单

- [ ] 确定 UI 设计稿（神话奇幻风格）
- [ ] 准备 JSON 数据文件（神兽/能力/属性/文化）
- [ ] AI 生成神兽图片素材（50-80 个）
- [ ] 准备 SVG 拼接素材（可选）
- [ ] 构建 AI 提示词模板库
- [ ] 开发首页
- [ ] 开发列表页（多维度分类）
- [ ] 开发详情页
- [ ] 开发搜索功能
- [ ] 开发收藏/历史功能
- [ ] 开发神话百科
- [ ] 开发 AI 生成器
- [ ] 开发互动功能（占卜/测试）
- [ ] 测试 & 优化性能
- [ ] 提交华为商店审核

---

## 十、未来扩展方向

### 10.1 社交功能
- 用户分享自己生成的神兽
- 神兽图鉴完成度排行榜
- 评论和点赞系统

### 10.2 游戏化
- 神兽收集成就系统
- 属性克制对战模拟
- 神兽进化/融合系统

### 10.3 AR 功能
- AR 观看神兽 3D 模型
- AR 拍照合影

### 10.4 内容扩展
- 更多文化体系（玛雅、阿兹特克、非洲部落神话）
- 现代创作神话（克苏鲁神话、SCP 基金会）
- 用户投稿神话生物

---

**文档版本:** v1.0
**技术方案:** 纯前端 + AI 生成图片（预置 or API）
**最后更新:** 2025年12月
