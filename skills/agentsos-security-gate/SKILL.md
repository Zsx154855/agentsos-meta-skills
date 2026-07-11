---
name: agentsos-security-gate
description: Claude Code 项目安全硬化协议——六门串联审计与修复流程。涵盖密钥治理、权限最小化、范围审计、工作区清理、远端验证、合并前冻结。任何 Claude Code 项目都可以用这套协议在合并前完成完整的安全硬化。触发词：「安全 Gate」「安全硬化」「安全审计」「执行安全 Gate」「六门审计」「security gate」。
---

# AgentsOS Security Gate Protocol

> 把安全从一次性审查变成可复用的操作系统级协议。
> 6 个 Gate，每个独立闭环、可回滚、可审计。

---

## 核心心智模型

### 1. 门禁式安全（Gated Security）

**一句话**：安全不是一条检查项，是一道道必须按序通过的门。前一道门的输出是后一道门的输入。

**应用方式**：
- 每个 Gate 有明确的 PASS / PARTIAL / BLOCKED 判定
- BLOCKED 不解锁不能进入下一 Gate
- 每个 Gate 的结果写入可审计报告
- 前门不通过，后门不开启

**来源**：6 个完整 Gate 在 PR #137 上的实际执行验证。

### 2. 多分身协作（Multi-Agent Oversight）

**一句话**：安全审查不能被单一视角的盲区限制。用多个独立分身交叉验证。

**角色分工**：

| 分身 | 职责 | 权限 |
|------|------|------|
| **H-ORC** | 总编排——管理范围、顺序和 Gate 流转 | 只读 |
| **H-SEC** | 密钥、权限、插件、配置安全审计 | 只读 |
| **H-EXE** | 执行本地修复——唯一可修改文件的分身 | 读写 |
| **H-GIT** | 工作区分类、Git 状态、提交边界 | 只读（除 git add/commit） |
| **H-CRI** | 最终审查——检查遗漏、伪修复、越权 | 只读 |
| **H-MEM** | 保持项目命名、路径和历史边界一致 | 只读 |

**关键规则**：只有 H-EXE 能修改文件。其他分身分析、审查、推荐。发现问题和执行修复分离，防止自我审查偏差。

### 3. 不可逆操作停审（Irreversible-Op Pause）

**一句话**：任何不可逆操作（push、merge、deploy、force push、rm -rf）必须在执行前触发审批停审。

**阻断清单**：
- git push / force push
- git merge / rebase
- git tag / release
- git reset --hard / git clean -fd
- rm -rf / sudo
- deploy / 外部发送
- 输出 secret / Keychain 读取

这些操作在 Gate 执行期间永远需要用户明确审批。

---

## 六门协议（6-Gate Protocol）

```
Gate 1: 密钥扫描与脱敏
  ↓
Gate 2: 权限最小化硬化
  ↓
Gate 3: 范围审计与拆分
  ↓
Gate 4: 工作区物理归类
  ↓
Gate 5: 远端验证
  ↓
Gate 6: 合并前最终冻结
```

每个 Gate 独立闭环，产出可审计报告。

---

### Gate 1: 密钥扫描与脱敏

**目标**：发现并清除所有活动配置中的明文凭据。

**检查清单**：
- [ ] 扫描 `.env` / `.env.*` / `webapp/.env*`
- [ ] 扫描 `settings.json` / `settings.local.json` 的 `env` 字段
- [ ] 扫描 allow 规则中的嵌入凭据（Bearer token, sk-, bot token）
- [ ] 扫描 tracked Git 文件中的 secret 模式
- [ ] 确认 Keychain 集成（macOS）
- [ ] 确认旧凭据已标记为「需在控制台撤销」

**工具**：
```bash
# 凭据变量名扫描（不输出值）
rg -n 'API_KEY|TOKEN|SECRET|PASSWORD|AUTH_TOKEN' .env .env.* 2>/dev/null

# 凭据模式扫描
rg -n 'sk-[a-z0-9]{20,}|Bearer [a-zA-Z0-9._-]{20,}|bot[0-9]+:AA' .env 2>/dev/null

# Git 跟踪文件 secret 扫描
git grep -l -E 'sk-[a-z0-9]{20,}'
```

**处置规则**：
- 项目 .env → 删除 API Key，仅保留 `DEEPSEEK_BASE_URL` 等非敏感配置
- webapp .env → 删除所有服务端 secret，严禁 `NEXT_PUBLIC_*KEY`
- 旧 Key 值 → 加入 `~/.config/agentsos/revoked-secret-archive/`（700/600）
- 新 Key → 仅写入 macOS Keychain 或仓库外 600 权限文件

**PASS 条件**：两个 .env 不含 API Key，webapp 不含服务端 secret，无 tracked secret。

---

### Gate 2: 权限最小化硬化

**目标**：收紧 Claude Code 的 allow/deny/ask 权限配置。

**检查清单**：
- [ ] 统计项目级 `allow / deny / ask` 数量
- [ ] 统计用户级 `allow / deny / ask` 数量
- [ ] 扫描危险 allow 规则
- [ ] 确认 `skipDangerousModePermissionPrompt: false`
- [ ] 确认 settings.json env 仅含非认证变量
- [ ] 确认 allow 规则中无嵌入凭据
- [ ] 确认文件权限为 600

**危险规则清单**（必须 deny 或 ask）：
```
Bash(*), Bash(python3 *), Bash(bash *), Bash(curl *), Bash(git *),
Bash(osascript *), Bash(open *), Bash(rm *), Bash(sudo *),
Bash(chmod *), Bash(kill *), Bash(launchctl *), Bash(security *),
Read(//tmp/**), Read(**/.env*), Read(**/.ssh/**), claude plugin *
```

**目标配置**：
```json
// 项目级
{ "allow": 3-13, "deny": 22+, "ask": 14 }

// 用户级
{ "allow": 0, "deny": 34+, "ask": 0 }
```

**PASS 条件**：无任意执行规则，无 git push/merge 自动允许，global allow 为空或最小化。

---

### Gate 3: 范围审计与拆分

**目标**：确保 PR 只包含目标范围内的文件，大型独立模块拆分为独立 PR。

**检查清单**：
- [ ] 统计 PR changed files 按目录分类
- [ ] 识别大型非 UI 模块（如 governance、ui_agent、core）
- [ ] 确定 pyproject.toml wheel scope
- [ ] 创建仓库外 archive 保存拆分模块
- [ ] 恢复 pyproject packages 到目标范围

**分类规则**：

| 类别 | 判定 | 处置 |
|------|------|------|
| Governance / UI Agent | 非 UI 框架 | 归档 → 独立 PR |
| Core / Kernel / Memory | 新 Runtime 模块 | 归档 → 独立 PR |
| Webapp UI | Figma B / RC2 | KEEP |
| Tauri Config | 打包配置 | KEEP |
| Security | .gitignore / test fixtures | KEEP |

**Archive 要求**：
- 目录：`~/.config/agentsos/scope-split/pr<N>-<timestamp>/`
- 格式：`tar.gz` + `checksums.sha256` + `split-readme.md`
- split-readme 必须包含：来源分支、HEAD、拆分时间、模块用途、后续 PR 建议

**PASS 条件**：Governance / UI Agent = 0 files in PR，wheel scope 恢复，archive 完整。

---

### Gate 4: 工作区物理归类

**目标**：untracked 文件归零（或全部在 .gitignore 中）。

**六类处置**：

| 类别 | 处置 | 示例 |
|------|------|------|
| **A. KEEP_IN_PR** | git add 指定文件 | AgentOSD 组件、not-found、ErrorBoundary |
| **B. SPLIT_TO_SEPARATE** | mv → scope-split archive | core/、scripts/、skills symlinks |
| **C. QUARANTINE_LOCAL** | mv → quarantine (700/600) | reports/、audits/、screenshots/ |
| **D. DELETE_GENERATED** | find -exec rm (精确路径) | __pycache__/、*.pyc、.mypy_cache/ |
| **E. IGNORE_LOCAL** | 加入 .gitignore | .venv*/、node_modules/、*.backup.* |
| **F. NEEDS_DECISION** | 标记待用户确认 | pnpm-lock.yaml、skills-lock.json |

**禁止操作**：
- git add . / git add -A
- git clean -fd / git reset --hard
- rm -rf
- 删除来源不明的业务代码

**PASS 条件**：untracked = 0，tracked modified = 0，staged = 0。

---

### Gate 5: 远端验证

**目标**：确认 PR 在 GitHub 上的状态可合并。

**检查清单**：
- [ ] local HEAD = remote HEAD
- [ ] git fetch + ahead/behind = 0/0
- [ ] 所有 required checks 通过
- [ ] Cloudflare Preview 成功
- [ ] GitGuardian / secret scan 通过
- [ ] review threads = 0
- [ ] mergeable = true
- [ ] isDraft = false
- [ ] 外部 App startup_failure 标记为 NON_BLOCKING

**工具**：
```bash
gh pr view <N> --json state,mergeable,reviewDecision,isDraft
gh pr checks <N>
gh api repos/<owner>/<repo>/commits/<sha>/check-runs
```

**PASS 条件**：required checks 全绿，local/remote 同步，0 review threads。

---

### Gate 6: 合并前最终冻结

**目标**：创建最终清理 commit，冻结 HEAD，输出 READY 信号。

**最终检查**：
- [ ] tracked modified = 0
- [ ] staged = 0
- [ ] untracked = 0
- [ ] secret scan CLEAN（tracked + staged + untracked）
- [ ] .gitignore 覆盖完整
- [ ] 最终 commit 已创建
- [ ] 所有工程验证 PASS（lint / typecheck / build / cargo / pytest）

**最终 commit 标题**：
```
chore(pr<N>): finalize scope and harden security boundaries before merge
```

**输出 READY 信号**：
```
✅ READY — PR #N 可进入 Squash Merge
推荐: gh pr merge N --squash --subject "feat: ..."
```

**PASS 条件**：所有指标归零，所有验证 PASS，commit 已创建，未 push/merge。

---

## 多分身协作协议

### 分身启动

每个 Gate 启动前，H-ORC 声明当前 Gate 目标和分工：

```
H-ORC：进入 Gate N — [目标]
H-SEC：负责 [安全检查项]
H-EXE：负责 [执行修复项]（唯一写权限）
H-GIT：负责 [Git 状态验证]
H-CRI：负责 [最终审查]
H-MEM：负责 [命名/路径一致性]
```

### 修改权限

- **H-EXE** 是唯一可修改文件的分身
- 其他分身只能 `Read` / `Bash(readonly)` / `Grep` / `Glob`
- H-EXE 执行修改后，H-CRI 独立验证

### 备份规则

任何修改前：
```bash
TS=$(date +%Y%m%d-%H%M%S)
cp <target> <target>.backup.$TS
chmod 600 <target>.backup.$TS
```

---

## 工具速查

### Secret 扫描
```bash
# 凭据变量名
rg -n 'API_KEY|TOKEN|SECRET|PASSWORD' .env .env.* 2>/dev/null

# 凭据模式（不输出值）
rg -c 'sk-[a-z0-9]{20,}' .env 2>/dev/null

# Git tracked
git grep -l -E 'sk-[a-z0-9]{20,}'

# SHA-256 比对（不输出值）
echo -n "$value" | shasum -a 256
```

### 权限统计
```bash
jq '{allow: (.permissions.allow|length), deny: (.permissions.deny|length), ask: (.permissions.ask|length)}' settings.local.json
jq '.skipDangerousModePermissionPrompt' settings.json
```

### 工作区统计
```bash
git status --short | wc -l                                    # 全部状态
git diff --name-only | wc -l                                  # tracked modified
git diff --cached --name-only | wc -l                         # staged
git ls-files --others --exclude-standard | wc -l              # untracked
git ls-files --others --exclude-standard | sed 's|/.*||' | sort | uniq -c | sort -rn  # 按目录
```

### 文件权限
```bash
stat -f "%N: %Sp" settings.local.json    # macOS
chmod 600 <file>                          # 锁定
```

### PR 状态
```bash
gh pr view <N> --json state,mergeable,reviewDecision,isDraft,headRefOid
gh pr checks <N>
gh api repos/<owner>/<repo>/commits/<sha>/check-runs --jq '.check_runs[] | {name, conclusion}'
```

---

## 诚实边界

1. **适用范围**：此协议基于 PR #137 的 6 个 Gate 实际执行提炼，适用于 Claude Code 项目的安全硬化场景。不涵盖应用层安全（XSS、SQL 注入等）。
2. **外部依赖**：DeepSeek/Anthropic API Key 轮换需要在服务商控制台手动完成，Gate 只能标记 MANUAL_REQUIRED，不能自动执行。
3. **误删风险**：Gate 4（工作区清理）涉及文件删除，必须严格遵循「先备份、再归类、后删除」流程。违反此顺序可能导致业务代码丢失。
4. **多分身模式**：多分身协作依赖 Claude Code 的 Agent/Workflow 能力。在不支持多分身的 runtime 中，需降级为串行检查。
5. **项目差异**：不同项目的 .gitignore、目录结构、技术栈不同，Gate 3/4 的分类规则需要适配，不能机械套用。
6. **审计追溯**：协议产出可审计报告，但不替代正式的 security audit 或 penetration test。

---

## 调研来源

**一手**（直接执行经验）：
- PR #137 (Zsx154855/AgentBotOS) 完整 6 个 Gate 的实际执行
- Gate 1: 密钥扫描 → 4 个 tracked 测试文件中 sk- 模式判定为 TEST_FIXTURE（SHA-256 比对）
- Gate 2: 项目级 allow 3→13 / deny 22 / ask 14；用户级 allow 0 / deny 34 / ask 0
- Gate 3: Governance (85 files) + UI Agent (52 files) → scope-split archive
- Gate 4: untracked 713→0（59 symlinks + 15 SPLIT tests + 4 SPLIT scripts + 39 SPLIT docs）
- Gate 5: required checks Cloudflare Pages ✅ + GitGuardian ✅；5× external App startup_failure → NON_BLOCKING
- Gate 6: final commit c640cd14 → fast-forward to 992b287d → squash merge 2761e45f

**方法论文献**：
- 女娲蒸馏方法论（alchaincyf/nuwa-skill）
- tonny Claude AI Builder 框架（生产杠杆 × vibecoding 加速 × 注意力变现管道）

---

> 本 Skill 由 [女娲 · Skill 造人术](https://github.com/alchaincyf/nuwa-skill) 生成
> 创建者：[花叔](https://x.com/AlchainHust)
> 蒸馏时间：2026-07-12
> 蒸馏方式：一手直接蒸馏（6 个 Gate 实际执行经验的完整提取）
> 这是目前最高质量的信息来源——执行者直接提炼自己的方法论，无需网络搜索
