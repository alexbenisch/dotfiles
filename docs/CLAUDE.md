Great data. Here's a comprehensive, current breakdown:

---

## Claude Code: Current Best Practices (2026)

A lot has shifted since the early "just chat with it" phase. The gap between average and high-output users is now almost entirely about **structure and workflow**, not prompting skill.

---

### 1. CLAUDE.md — Keep It Lean and Earned

This is still the #1 lever. Boris Cherny (the creator of Claude Code) shared his workflow publicly in January 2026: his CLAUDE.md file is only ~100 lines, but it consistently outperforms 800-line configs because every line earns its place — no filler, no "just in case" rules. Every rule exists because it solved a real problem.

His team's operating principle: after any correction, update `tasks/lessons.md` so the same mistake doesn't repeat. Ruthlessly iterate until the mistake rate drops.

What belongs in CLAUDE.md:
- Common bash commands for your project (`make test`, `flux reconcile`, etc.)
- Code style constraints specific to your stack
- Key architectural decisions ("Flux CD conventions only, no raw kubectl apply")
- Paths to important files Claude should always know about

**For your DevOps/Python work:** Add your Hetzner/k3s context, Flux CD conventions, FastAPI patterns you use. Keep it under 150 lines.

---

### 2. Plan Mode First — Always

Use `Shift+Tab` to switch Claude Code between planning mode and normal mode. Force it to think like a Senior Architect first before any implementation. Jumping straight into code feels productive but almost always creates downstream pain.

Anthropic's internal testing found that unguided attempts succeed about 33% of the time. Planning collapses 20 ambiguous decisions into a reviewed spec where each lands near 100%, because you've already made the call.

Practical workflow:
1. Enter plan mode → describe the task
2. Review the plan, correct it
3. Give the green light to execute

---

### 3. Context Window Is Your Primary Resource

Every file Claude reads, every command output, every message eats into your context window. When it fills up, Claude starts "forgetting" earlier instructions.

Key commands to manage this:
- `Esc` — stop Claude mid-action, context preserved, you can redirect
- `Esc + Esc` or `/rewind` — restore to a previous checkpoint
- `/clear` — reset context between **unrelated** tasks (most underused command per the community)

---

### 4. Parallel Worktrees — The Real Unlock

Boris Cherny's workflow that spread rapidly through the developer community: he runs 10–15 Claude Code sessions simultaneously, each pushing forward on a different task independently. Most developers use Claude Code with a single-threaded mindset — waiting for one task to complete before starting the next.

The primitive: `claude --worktree feature-auth` creates a branch called "feature-auth", checks it out in a separate directory, and launches Claude there. Multiple worktrees share git history but have independent file systems — no file conflicts between sessions.

Decision rule: only parallelize tasks that are fully independent with no shared file state. Worktrees are for long-running tasks requiring persistent code changes (tens of minutes to hours). Subagents are for short-lived research, search, or analysis tasks within a single session (minutes). The two can be combined — each worktree session can itself spawn subagents.

**Practical example for your stack:** Run one session doing Terraform changes on a feature branch, another writing tests for a FastAPI endpoint — completely isolated.

---

### 5. Hooks — Enforce What Prompts Can't

Hooks close the gap to 100% on certain behaviors by running scripts at specific points in Claude's workflow, making certain behaviors structurally impossible. Before-action hooks block a command entirely, forcing Claude to try a different approach. After-action hooks provide non-blocking feedback, like running a linter after every file edit and feeding the output back automatically.

Configured in `hooks` inside your Claude Code config:

```json
{
  "hooks": {
    "PostToolUse": [{ "command": "ruff check $FILE" }],
    "PreToolUse": [{ "command": "check-no-kubectl-apply.sh" }]
  }
}
```

One trap: never block file writes mid-plan. It breaks multi-step reasoning because Claude loses track of where it is in the sequence. Let it finish writing, then validate through after-action hooks.

---

### 6. Subagents for Exploration, Not Your Main Session

When you genuinely need broad investigation, delegate it to a subagent so the exploration does not consume your main context.

In practice: "Search the codebase for all places that reference X and summarize" → delegate to subagent. Your main session stays clean for the actual implementation work.

---

### 7. The `cc` Alias + MCP Servers

Add `alias cc='claude --dangerously-skip-permissions'` to `~/.zshrc` and run source. Type `cc` instead of `claude` and skip every permission prompt. Use this only in your homelab/personal repos where you trust the context.

MCP servers are now a major productivity surface — connect your tools (GitHub, internal APIs) so Claude can interact with them directly rather than you copy-pasting outputs back in.

---

### 8. Task Tracking in the Repo

The task management workflow: write a plan to `tasks/todo.md` first, verify the plan before starting, mark items complete as you go, add a review section to `todo.md` when done, and capture lessons in `lessons.md` after any correction.

This is especially powerful for long-running features — it survives context resets and gives Claude a ground truth to refer back to.

---

**TL;DR for your workflow:** CLAUDE.md (lean, 100 lines), plan mode before every non-trivial task, `--worktree` for parallel isolation, hooks for non-negotiable behaviors (linting, style enforcement, Flux conventions), `/clear` aggressively between unrelated tasks. The gap is entirely in the scaffolding, not the prompts.
