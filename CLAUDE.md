# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**神兽志 (Mythical Bestiary)** - 一款聚焦全球神话生物的图鉴类工具 App，面向奇幻游戏玩家、神话爱好者、DND/TRPG 玩家等用户群体。

- **平台**: 鸿蒙 HarmonyOS
- **技术方案**: 纯前端项目，无后端服务，纯单机离线应用
- **开发语言**: ArkTS
- **数据存储**: 本地 JSON 文件 + LocalStorage
- **需求文档**: 神话生物图鉴-PRD.md

---

## 重要开发约束

### 1. 文档优先原则
- **编写任何代码之前必须查询** `harmonyos_docs/文档索引.md`
- 严格按照鸿蒙官方文档约束编写代码
- 不可自行发挥，必须遵循文档规范

### 2. 编译验证
- **每完成一个功能必须运行编译检查**:
```bash
hvigorw assembleHap
```
- 必须确保编译没有任何错误才能继续下一个功能

### 3. 图片资源约束
- **禁止使用线上图片** - 这是纯单机离线应用
- **禁止文件夹嵌套** - 鸿蒙图片资源不允许文件夹嵌套
- **所有图片必须放在** `entry/src/main/resources/base/media/` 目录下（同一层级）
- 图片命名规范：使用下划线分隔，如 `creature_dragon_fire.png`

### 4. 图标约束
- **禁止使用 emoji**
- 所有图标必须生成 SVG 文件放到 `base/media` 目录
- SVG 命名规范：`ic_xxx.svg`（如 `ic_fire.svg`, `ic_water.svg`）

### 5. AI 生图要求
- 使用 `example.py` 作为 AI 生图模板
- **不可修改** baseURL、apikey、请求模型
- **每个类目至少 20 张图片**
- 页面采用沉浸式设计，背景图片全部使用 AI 生成

---

## 开发命令

```bash
# 编译项目（每完成一个功能必须运行）
hvigorw assembleHap

# 运行到模拟器
hvigorw installHapDebug

# 清理构建
hvigorw clean
```

---

## 项目架构

### 核心模块划分

1. **图鉴浏览模块** - 按文化/属性/类型/阵营分类浏览神兽
2. **神话百科模块** - 属性元素、文化体系、能力词典
3. **神兽生成器模块** - 离线 SVG 素材拼接（不使用在线 API）
4. **本地数据模块** - 收藏、历史记录、用户创建的神兽
5. **互动娱乐模块** - 每日占卜、属性测试
6. **搜索模块** - 纯本地搜索，过滤 JSON 数据

### 目录结构

```
entry/src/main/
├── ets/
│   ├── pages/
│   │   ├── Index.ets              // 首页
│   │   ├── CreatureList.ets       // 神兽列表
│   │   ├── CreatureDetail.ets     // 神兽详情
│   │   ├── AbilityList.ets        // 能力百科
│   │   ├── CultureList.ets        // 文化体系列表
│   │   ├── Generator.ets          // 神兽生成器
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
│   │   └── GeneratorCanvas.ets    // 生成器画布
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
│   │   ├── ImageExport.ets        // 图片导出工具
│   │   └── Search.ets             // 搜索工具
│   │
│   └── common/
│       ├── Constants.ets          // 常量定义
│       └── Theme.ets              // 主题配置
│
└── resources/
    └── base/
        └── media/                 // 所有图片资源（不可嵌套文件夹）
            ├── creature_xxx.png   // 神兽图片
            ├── bg_xxx.png         // 背景图片
            ├── ic_xxx.svg         // 图标 SVG
            └── ...
```

---

## 资源命名规范

### 图片命名
```
神兽图片:     creature_{文化}_{名称}.png
             例: creature_chinese_dragon.png
             例: creature_greek_phoenix.png

背景图片:     bg_{用途}.png
             例: bg_home.png
             例: bg_detail.png

属性图标:     ic_attr_{属性}.svg
             例: ic_attr_fire.svg
             例: ic_attr_water.svg

功能图标:     ic_{功能}.svg
             例: ic_search.svg
             例: ic_favorite.svg

文化图标:     ic_culture_{文化}.svg
             例: ic_culture_chinese.svg
```

### 图片数量要求
每个类目至少 20 张图片：
- 中国神话: 20+ 张
- 希腊神话: 20+ 张
- 北欧神话: 20+ 张
- 日本神话: 20+ 张
- 其他文化: 20+ 张

---

## 数据结构设计

### MythicalCreature (神兽数据)
```typescript
interface MythicalCreature {
  id: string;
  name: {
    original: string;
    cn: string;
    en: string;
  };
  culture: 'chinese' | 'greek' | 'norse' | 'japanese' | 'indian' | 'egyptian' | 'celtic';
  type: 'dragon' | 'phoenix' | 'beast' | 'spirit' | 'giant' | 'undead';
  attributes: {
    primary: 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';
    secondary?: string;
  };
  alignment: 'guardian' | 'neutral' | 'evil';
  rarity: 'legendary' | 'epic' | 'rare' | 'common';
  description: string;
  mythology: string;
  abilities: string[];
  symbolism: string;
  image: string;           // 图片文件名（不含路径）
  related: string[];
  tags: string[];
}
```

### Attribute (属性数据)
```typescript
interface Attribute {
  id: string;
  name_cn: string;
  name_en: string;
  color: string;           // 主色值
  icon: string;            // SVG 图标文件名
  meaning: string;
  strengths: string[];
  weaknesses: string[];
}
```

---

## 属性配色方案

| 属性 | 主色 | 辅色 | 图标文件 |
|------|------|------|----------|
| 火 | #ff4500 | #ff8c00 | ic_attr_fire.svg |
| 水 | #1e90ff | #00ced1 | ic_attr_water.svg |
| 风 | #7fffd4 | #98fb98 | ic_attr_wind.svg |
| 雷 | #9370db | #8a2be2 | ic_attr_thunder.svg |
| 光 | #ffd700 | #ffffe0 | ic_attr_light.svg |
| 暗 | #2f4f4f | #191970 | ic_attr_dark.svg |
| 自然 | #228b22 | #3cb371 | ic_attr_nature.svg |

---

## 开发流程

### 功能开发步骤
1. **查阅文档**: 先查看 `harmonyos_docs/文档索引.md` 了解相关 API
2. **编写代码**: 严格按照文档规范编写
3. **编译验证**: 运行 `hvigorw assembleHap` 确保无错误
4. **测试功能**: 在模拟器中验证功能正常
5. **进入下一功能**: 确认无误后再开发下一个功能

### 图片资源准备
1. 修改 `example.py` 脚本生成所需图片
2. 确保图片放在 `base/media/` 目录下（不嵌套）
3. 使用规范的命名方式
4. 每个类目至少 20 张图片

---

## 关键技术实现

### 1. 数据加载 (DataLoader.ets)
- 从 `resources/rawfile/data/` 加载 JSON 数据
- 使用 `getContext().resourceManager.getRawFileContent()` 读取
- 启动时一次性加载所有数据到内存

### 2. 本地存储 (Storage.ets)
- 使用 `@ohos.data.preferences` 封装持久化
- 存储内容：收藏列表、用户创建的神兽、浏览历史

### 3. 图片加载
```typescript
// 正确方式：使用 $r 引用 media 目录下的图片
Image($r('app.media.creature_chinese_dragon'))

// 错误方式：不要使用路径或网络图片
// Image('https://...') ❌
// Image('/path/to/image') ❌
```

### 4. 沉浸式页面设计
- 背景图片使用 AI 生成
- 全屏沉浸式布局
- 渐变遮罩处理文字可读性

---

## 注意事项

1. **绝对禁止**使用网络请求加载图片
2. **绝对禁止**在 media 目录下创建子文件夹
3. **绝对禁止**使用 emoji，必须用 SVG 图标替代
4. **每个功能完成后必须**运行编译检查
5. **编写代码前必须**查阅鸿蒙文档
6. 所有图标使用 SVG 格式，放在 `base/media/` 目录
7. 图片命名使用小写字母和下划线
