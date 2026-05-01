import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

function findGitRepoRoot(startDir: string): string | null {
  let dir = resolve(startDir);
  while (true) {
    if (existsSync(join(dir, ".git"))) {
      return dir;
    }
    const parent = dirname(dir);
    if (parent === dir) {
      return null;
    }
    dir = parent;
  }
}

function collectClaudeSkillDirs(startDir: string): string[] {
  const skillDirs: string[] = [];
  const resolvedStartDir = resolve(startDir);
  const gitRepoRoot = findGitRepoRoot(resolvedStartDir);
  let dir = resolvedStartDir;
  while (true) {
    skillDirs.push(join(dir, ".claude", "skills"));
    if (gitRepoRoot && dir === gitRepoRoot) {
      break;
    }
    const parent = dirname(dir);
    if (parent === dir) {
      break;
    }
    dir = parent;
  }
  return skillDirs;
}

export default function (pi: ExtensionAPI) {
  pi.on("resources_discover", async (event, _ctx) => {
    const dirs = collectClaudeSkillDirs(event.cwd);
    // Only return dirs that actually exist
    const skillPaths = dirs.filter((d) => existsSync(d));
    if (skillPaths.length > 0) {
      return { skillPaths };
    }
    return undefined;
  });
}
