#!/usr/bin/env bash
set -e -u -o pipefail

# Configuration - override via environment variables
TUICR_PANE_POSITION="${TUICR_PANE_POSITION:-top}"    # top or bottom
TUICR_PANE_SIZE="${TUICR_PANE_SIZE:-80}"              # ignored in zellij (uses default tiled sizing)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[tuicr]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[tuicr]${NC} $*"
}

log_error() {
  echo -e "${RED}[tuicr]${NC} $*"
}

usage() {
  cat << EOF
Usage: $(basename "$0") [directory]

Launch tuicr in a zellij split pane to review git changes.

Arguments:
  directory    Git repository directory to review (default: current directory)

Environment variables:
  TUICR_PANE_POSITION   Position of tuicr pane: top or bottom (default: top)
  TUICR_PANE_SIZE       Ignored in zellij (uses default tiled sizing)

Examples:
  $(basename "$0")                    # Review changes in current directory
  $(basename "$0") ~/project          # Review changes in ~/project
  TUICR_PANE_POSITION=bottom $(basename "$0")
EOF
}

check_zellij() {
  if [[ -z "${ZELLIJ:-}" ]]; then
    return 1
  fi
  return 0
}

check_tuicr() {
  if ! command -v tuicr &> /dev/null; then
    log_error "tuicr not found. Install it first."
    return 1
  fi
  return 0
}

check_tuicr_stdout_support() {
  # Check if tuicr supports --stdout flag
  tuicr --help 2>&1 | grep -q -- '--stdout'
}

check_git_repo() {
  local dir="$1"
  if ! git -C "$dir" rev-parse --git-dir &> /dev/null; then
    log_error "Not a git repository: $dir"
    return 1
  fi
  return 0
}

check_tuicr_running() {
  # Check if tuicr is already running in any zellij pane
  if zellij action list-panes -c -j 2>/dev/null | grep -q '"tuicr"'; then
    return 0  # tuicr is running
  fi
  return 1
}

launch_tuicr_pane() {
  local target_dir="$1"

  log_info "Launching tuicr in $TUICR_PANE_POSITION pane"
  log_info "Directory: $target_dir"

  # Create unique files for output capture and sentinel
  local output_file=""
  local done_file
  done_file=$(mktemp /tmp/tuicr-done.XXXXXX)
  local tuicr_cmd="tuicr"
  local use_stdout=false

  if check_tuicr_stdout_support; then
    output_file=$(mktemp /tmp/tuicr-output.XXXXXX)
    tuicr_cmd="tuicr --stdout > '$output_file'"
    use_stdout=true
    log_info "Using --stdout mode (output will be captured)"
  else
    log_warn "tuicr --stdout not supported, output will be copied to clipboard"
  fi

  # Write a temp script to avoid nested quoting issues
  local script_file
  script_file=$(mktemp /tmp/tuicr-script.XXXXXX)
  cat > "$script_file" << EOF
trap 'touch "$done_file"' EXIT INT TERM
cd "$target_dir" || exit 1
$tuicr_cmd
EOF
  chmod +x "$script_file"

  # Create the split pane with tuicr
  local new_pane_id
  new_pane_id=$(zellij action new-pane --direction down --close-on-exit --cwd "$target_dir" --name "tuicr" -- "$script_file")

  # If top position requested, move the new pane up
  if [[ "$TUICR_PANE_POSITION" == "top" ]]; then
    zellij action move-pane -p "$new_pane_id" up
  fi

  log_info "tuicr is running in pane $new_pane_id"
  log_info "Waiting for tuicr to exit..."

  # Poll until tuicr exits (sentinel file created)
  local max_wait=600
  local waited=0
  while [[ ! -f "$done_file" ]] && [[ $waited -lt $max_wait ]]; do
    sleep 1
    ((waited++))
  done

  if [[ ! -f "$done_file" ]]; then
    log_warn "Timed out waiting for tuicr (10 minutes)"
  fi

  log_info "tuicr finished"

  # Clean up temp script
  rm -f "$script_file"

  # Output captured instructions if --stdout was used
  if [[ "$use_stdout" == true ]] && [[ -f "$output_file" ]]; then
    if [[ -s "$output_file" ]]; then
      echo ""
      echo "=== TUICR INSTRUCTIONS ==="
      cat "$output_file"
      echo "=== END TUICR INSTRUCTIONS ==="
    else
      log_info "No instructions exported from tuicr"
      log_info "If you exported to clipboard, paste the instructions here"
    fi
    rm -f "$output_file"
  else
    log_info "If you exported instructions, they are in your clipboard - paste them here"
  fi

  rm -f "$done_file"
}

main() {
  # Handle help
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  # Check for tuicr
  if ! check_tuicr; then
    exit 1
  fi

  # Determine target directory
  local target_dir="${1:-.}"
  target_dir=$(cd "$target_dir" && pwd)  # Get absolute path

  # Verify it's a git repo
  if ! check_git_repo "$target_dir"; then
    exit 1
  fi

  # Check if we're in zellij
  if ! check_zellij; then
    log_error "Not running inside zellij!"
    echo ""
    echo "To use tuicr with your coding agent, run that agent inside zellij."
    echo ""
    echo "1. Exit the current agent session."
    echo ""
    echo "2. Restart the agent inside zellij."
    echo ""
    echo "3. Then run /tuicr again."
    exit 1
  fi

  # Check if tuicr is already running
  if check_tuicr_running; then
    log_warn "tuicr is already running in another pane"
    log_info "Switch to it with Alt + arrow keys (or Ctrl + p then arrow keys)"
    exit 0
  fi

  # Launch tuicr in a split pane
  launch_tuicr_pane "$target_dir"
}

main "$@"
