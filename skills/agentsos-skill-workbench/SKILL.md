---
name: agentsos-skill-workbench
description: Skill 工作台——用女娲蒸馏 × 安全 Gate 验证 × tonny 商业化评估，把任何人物/主题/方法论变成可安全分发的 AI Skill。触发词：「skill 工作台」「工作台蒸馏 XX」「skill 流水线」「发布一个 skill」。
---

# AgentsOS Skill Workbench

> 女娲造人 → 安全 Gate → tonny 评估。
> 把原材料变成可安全分发的 AI Skill 的一条龙管道。

## 管道流程

```
  输入（人名/主题/URL/方法论）
    ↓
  [Phase 1: 女娲蒸馏]
    提取心智模型、启发式、表达 DNA
    输出: SKILL.md + references/
    ↓
  [Phase 2: 安全 Gate 验证]
    Secret 扫描、权限检查、结构验证
    输出: 安全报告（PASS/FAIL/IMPROVE）
    ↓
  [Phase 3: tonny 商业化评估]
    分发价值、变现潜力、建造建议
    输出: Builder Report
    ↓
  最终输出: Skill Readiness Report
  ┌─────────────────────────────┐
  │ PASS → 可分发 / 可开源       │
  │ IMPROVE → 标注薄弱维度       │
  │ BLOCKED → 标注阻断原因       │
  └─────────────────────────────┘
```

## Phase 1: 女娲蒸馏

调用 `huashu-nuwa` skill 执行完整蒸馏：

```
用女娲蒸馏 [目标]，要求：
- 六路并行采集 + 三重验证提炼
- 输出 SKILL.md 到 .claude/skills/[name]-perspective/
- 注明信息源质量和诚实边界
```

**Checkpoint**：SKILL.md 已生成，调研文件完整。

蒸馏质量快速检查：
- [ ] 心智模型 3-7 个
- [ ] 每个模型有来源证据
- [ ] 有明确局限和诚实边界
- [ ] 表达 DNA 有辨识度
- [ ] 内在张力 ≥2 对

---

## Phase 2: 安全 Gate 验证

对生成的 SKILL.md 执行安全检查：

```bash
# Secret scan
rg -c 'sk-[a-z0-9]{20,}|Bearer [a-zA-Z0-9._-]{20,}|bot[0-9]+:AA' SKILL.md

# 确保没有真实凭据
# 确保没有本地绝对路径泄露
# 确保没有旧项目名错误引用
```

**检查清单**：
- [ ] 无真实 API Key / Token / Secret
- [ ] 测试桩使用 `TEST_ONLY_NOT_A_REAL_SECRET` 格式
- [ ] 无绝对路径泄露
- [ ] 无旧项目名（如 AgentOS → AgentsOS）
- [ ] SKILL.md 文件权限 644（可读但不可执行）
- [ ] 父目录权限合理

**Checkpoint**：安全报告 CLEAN 或标注问题。

---

## Phase 3: tonny 商业化评估

用 `tonny-claude-ai-builder-perspective` 视角评估 Skill：

**评估维度**：
1. **可分发性**：这个 Skill 能独立使用吗？还是依赖特定环境？
2. **变现潜力**：谁能从这个 Skill 受益？他们会付费吗？
3. **建造建议**：如何把这个 Skill 变成可运行的产品？
4. **分发渠道**：GitHub / skills.sh / 社区 marketplace？

**输出格式**：
```
### tonny Builder 评估

**可分发性**: [1-5] — 原因
**变现潜力**: [1-5] — 原因
**建造建议**: [具体下一步]
**分发渠道**: [推荐渠道]
**整体评级**: READY / NEEDS_WORK / EXPERIMENTAL
```

---

## 最终输出：Skill Readiness Report

```
╔══════════════════════════════════════╗
║   AGENTSOS SKILL READINESS REPORT   ║
╠══════════════════════════════════════╣
║ Skill: [name]                        ║
║ Phase 1 (女娲): [PASS/IMPROVE]       ║
║ Phase 2 (安全): [PASS/BLOCKED]        ║
║ Phase 3 (tonny): [READY/NEEDS_WORK]   ║
╠══════════════════════════════════════╣
║ Overall: [PASS/IMPROVE/BLOCKED]      ║
╚══════════════════════════════════════╝
```

---

## 执行模式

### 完整管道（默认）
对一个新的蒸馏目标，串行执行 Phase 1-2-3。

### 单 Phase 模式
对已有 SKILL.md，跳过 Phase 1：
```
skill 工作台 验证 [skill-name]
```

### 批量模式
对 `.claude/skills/` 下的所有 skill 执行 Phase 2+3：
```
skill 工作台 审计全部
```

---

## 与独立 Skill 的关系

| 独立使用 | 工作台管道 |
|---------|-----------|
| `蒸馏乔布斯` → 生成 SKILL.md | → 自动验证 → 自动评估 → 给出可分发判断 |
| 手动检查 secret | 自动扫描 |
| 手动判断商业化 | 自动评估 |

工作台把三个独立 Skill 的认知劳动自动化了。

---

## 诚实边界

1. **Phase 1 质量依赖信息源**：无法访问的付费墙内容会限制蒸馏深度。
2. **Phase 2 不涵盖应用层安全**：只检查凭据泄露和文件结构，不审计应用代码。
3. **Phase 3 是评估不是保证**：tonny 的变现评估基于框架推断，不是市场验证。
4. **人工审查不可替代**：工作台加速流程，但最终的可分发判断需要人工确认。

---

> 本 Skill 由 AgentsOS Skill Workbench 自身建造 — 吃了自己的狗粮
> 建造时间：2026-07-12
> 核心依赖：huashu-nuwa / agentsos-security-gate / tonny-claude-ai-builder-perspective
