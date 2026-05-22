规划或更新当前 work repo 在月光酒馆中的 ROADMAP.md，基于产品文档和设计稿进行 brainstorm。

## 前置条件

- 需要月光酒馆中的 repos.yml 和对应项目的 ROADMAP.md
- 当前在 work repo 或月光酒馆目录中均可运行

## 步骤

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆。

### 1. 确定当前项目

通过 git remote 获取当前仓库的 `org/repo`，在 repos.yml 中查找匹配的 name：

```bash
git remote get-url origin | sed 's/.*:\(.*\)\.git/\1/'
```

匹配 repos.yml 中的 github 字段，获取项目名 `PROJECT_NAME`。

### 2. 收集已有素材

读取所有可用于 brainstorm 的源材料：

**2.1 现有 ROADMAP.md**

```bash
cat {月光酒馆路径}/projects/{PROJECT_NAME}/ROADMAP.md
```

如果不存在，说明是全新规划。

**2.2 产品文档（PRD）**

在 work repo 中搜索 PRD 相关文件：

```bash
# 查找 PRD 文件
find . -maxdepth 2 -iname "*prd*" -o -iname "*product*" -o -iname "*需求*" -o -iname "*spec*" 2>/dev/null | head -10
```

如果有，逐文件读取内容。

**2.3 设计稿 / 设计文档**

```bash
find . -maxdepth 2 \( -iname "*design*" -o -iname "*ui*" -o -iname "*figma*" \) 2>/dev/null | head -10
```

如果有设计文档（非图片），读取内容。

**2.4 当前项目结构**

用少量命令了解项目定位：

```bash
ls src/ 2>/dev/null || ls app/ 2>/dev/null || ls lib/ 2>/dev/null || echo "无标准源码目录"
cat package.json 2>/dev/null | head -20 || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
```

**2.5 git 提交历史（了解已做功能）**

```bash
git log --oneline -20 2>/dev/null
```

### 3. Brainstorm

综合以上所有素材进行头脑风暴，输出 ROADMAP.md。思考框架：

1. **产品定位** — 这个项目到底在解决什么问题？
2. **目前已做了什么** — 从 git log 和现有 ROADMAP.md 梳理已交付功能
3. **缺失什么** — 对比 PRD / 设计稿 / 产品目标，识别 gap
4. **优先级排序** — 按用户价值 + 技术依赖关系排阶段
5. **分阶段输出** — 当前阶段用 `- [ ]` 表示待办，后续阶段保持粗粒度

### 4. 输出 ROADMAP.md

```markdown
# {项目名} — 路线图

## 产品定位
{brainstorm 得出的产品定位一句话}

## 当前阶段

### Phase {N} · {阶段名}（进行中）

- [ ] {Milestone 1：一句话描述}
- [ ] {Milestone 2}

### Phase {N-1} · {阶段名}（已完成）

- [x] {已完成 Milestone}

## 后续阶段

### Phase {N+1} · {阶段名}（待规划）

- [ ] 待定

## 附录

### 参考来源
- PRD: {文件名}
- 设计稿: {文件名}
- 其他: {文件名}
```

### 5. 写入文件

将生成的 ROADMAP.md 写入：

```bash
{月光酒馆路径}/projects/{PROJECT_NAME}/ROADMAP.md
```

### 6. 输出总结

展示变更摘要：
```
✅ {项目名} ROADMAP 已更新

当前阶段：Phase {N} · {阶段名}
里程碑：X 个待办 · Y 个已完成
```

## 注意

- 本命令是增强现有 ROADMAP.md，不要删除已有内容
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
