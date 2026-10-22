/**
 * Caveman Extension
 *
 * Loads the caveman skill on session start. This is the Pi equivalent of the
 * Claude Code SessionStart hook in ~/.claude/settings.json: the full SKILL.md
 * is injected as a system prompt section so the voice applies from the first
 * response.
 *
 * Skill resolution order: $CAVEMAN_SKILL_PATH, ~/.agents/skills/caveman,
 * ~/.claude/skills/caveman, ~/.pi/agent/skills/caveman.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const ACTIVATION_NOTE =
	'Caveman mode: caveman. The caveman skill is active for this session. ' +
	'Apply the rules below to every response. Stop the voice with "stop caveman" or "normal mode".';

function findCavemanSkillPath(): string | null {
	const candidates: string[] = [];
	const override = process.env.CAVEMAN_SKILL_PATH;
	if (override) {
		candidates.push(override);
	}
	candidates.push(
		join(homedir(), ".agents", "skills", "caveman", "SKILL.md"),
		join(homedir(), ".claude", "skills", "caveman", "SKILL.md"),
		join(homedir(), ".pi", "agent", "skills", "caveman", "SKILL.md"),
	);

	for (const candidate of candidates) {
		if (existsSync(candidate)) {
			return candidate;
		}
	}
	return null;
}

function stripFrontmatter(markdown: string): string {
	const match = markdown.match(/^---\r?\n[\s\S]*?\r?\n---\r?\n/);
	if (!match) {
		return markdown;
	}
	return markdown.slice(match[0].length);
}

function loadCavemanSection(): string | null {
	const skillPath = findCavemanSkillPath();
	if (!skillPath) {
		return null;
	}
	try {
		const body = stripFrontmatter(readFileSync(skillPath, "utf8")).trim();
		return `${ACTIVATION_NOTE}\n\n${body}`;
	} catch {
		return null;
	}
}

export default function caveman(pi: ExtensionAPI) {
	const section = loadCavemanSection();

	pi.on("session_start", (_event, ctx) => {
		if (section === null) {
			ctx.ui.notify("caveman extension: caveman SKILL.md not found; the skill was not loaded", "warning");
		}
	});

	pi.on("before_agent_start", (event) => {
		if (section === null) {
			return;
		}
		event.systemPromptOptions.sections.caveman = section;
	});
}
