  #!/usr/bin/env bash
  set -euo pipefail

  get_internal() {
    swaymsg -rt get_outputs \
      | jq -r '.[] | select(.active and (.name | test("^(eDP|LVDS)"))) | .name' \
      | head -n1
  }

  get_hdmi() {
    swaymsg -rt get_outputs \
      | jq -r '.[] | select(.active and (.name | test("^HDMI"))) | .name' \
      | head -n1
  }

  apply_layout() {
    local internal hdmi target ws1 focused
    internal="$(get_internal)"
    [[ -z "${internal}" ]] && return 0

    hdmi="$(get_hdmi)"
    target="$internal"
    [[ -n "${hdmi}" ]] && target="$hdmi"

    focused="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .name')"
    ws1="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == 1) | .name' | head -n1 || true)"

    # Keep workspace 1 on internal panel
    if [[ -n "${ws1}" ]]; then
      swaymsg "workspace \"${ws1}\"; move workspace to output \"${internal}\"" >/dev/null
    fi

    # Move all other existing workspaces to target (HDMI if present, else internal)
    swaymsg -rt get_workspaces \
      | jq -r '.[] | select(.num != 1) | .name' \
      | while IFS= read -r ws; do
          [[ -n "${ws}" ]] || continue
          swaymsg "workspace \"${ws}\"; move workspace to output \"${target}\"" >/dev/null
        done

    [[ -n "${focused}" ]] && swaymsg "workspace \"${focused}\"" >/dev/null
  }

  apply_layout
  swaymsg -mt subscribe '["output"]' | while read -r _; do
    apply_layout
  done
