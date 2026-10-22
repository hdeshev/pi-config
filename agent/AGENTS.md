<!-- codebase-memory-mcp:start -->
# Codebase Memory

## Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

### Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `check_index_coverage` — validate candidate paths and missed ranges before claims
5. `query_graph` — run Cypher queries for complex patterns
6. `get_architecture` — high-level project summary

### Evidence tiers
- **Scout (Tier 1):** quick positive lookup with few calls and targeted source checks. Mark it provisional; do not make negative or exhaustive claims.
- **Verify (Tier 2, default):** task-directed graph evidence, relevant trace directions, exact snippets for material claims, and relevant pagination.
- **Auditor (Tier 3):** bounded-scope full verification with current generation, complete relevant pagination, both call directions and broader relationships when material, and every limitation disclosed.
- After candidate paths are known in any tier, call `check_index_coverage` once with every evidence path. Add relevant scopes for negative or exhaustive claims. A clean result means no recorded gap, not proof of completeness. For partial, skipped, excluded, stale, pending, or unknown coverage, read/grep the reported ranges or scope before relying on graph results.

### When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

### Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`

### Session resets and subagents
- At session start or after compaction, confirm the nearest graph project and generation with `list_projects` or `index_status`, then choose Scout, Verify, or Auditor.
- Before spawning a subagent, query the graph and coverage in the parent. Pass the tier, project, generation/freshness, bounded scope, queries and pagination state, qualified symbols, paths, call-chain findings, coverage evidence with ranges/reasons, source fallback already performed, and unresolved questions in the delegated task context.
- Do not assume subagents inherit MCP access or the parent conversation. If a child lacks MCP tools, it must not call or claim MCP access. It should use the supplied evidence and read/grep exact source, especially every reported missed-coverage range.
<!-- codebase-memory-mcp:end -->

# Code references

Always format references to code and files as Markdown links with a GitHub-style line
fragment. Resolve every path relative to the current working directory, and put the line
number in the link text with a colon.

- With a line number: `[file.cs:42](path/to/file.cs#L42)`
- With a range: `[file.cs:42-50](path/to/file.cs#L42-L50)`
- Without a line number: `[file.cs](path/to/file.cs)`

Rules:

- Apply this to chat answers and to Markdown files that you write or edit.
- Never leave a bare file path or a code symbol without a link when the link identifies the code.
- Never use absolute paths.
- If a repository convention or local skill names a different base directory, the current
  working directory wins for the links you write.

## Test runners: use rtk wrappers

This setup uses `rtk` (`~/.local/bin/rtk`), a CLI proxy that filters and summarizes
command output before it reaches model context. **Prefer `rtk` wrapper commands over raw
invocations** for tests, so large repetitive output does not flood the session.

- `rtk test <command...>` — run any test command, show only failures.
- `rtk dotnet test` — .NET tests with compact output (also `rtk dotnet build|restore|format`).
- `rtk npm test`, `rtk jest`, `rtk vitest`, `rtk ctest`, `rtk cargo test`, `rtk playwright` — stack-specific runners.

Rules:

- Flags and filters pass through to the wrapped tool, e.g. `rtk dotnet test --filter FullyQualifiedName~Foo`.
- Use `--shell '<quoted string>'` when the command must run through a shell.
- Fall back to the raw command only when `rtk` drops output you need for diagnosis (crash
dumps, hang traces, full TRX detail), and say why in the response.
- Same principle for non-test work: `rtk rg`, `rtk grep`, `rtk read`, `rtk git`, `rtk docker`,
`rtk kubectl`, `rtk json`, `rtk diff` beat the raw equivalents.
- `rtk gain` reports token savings; `rtk --help` lists every subcommand.
