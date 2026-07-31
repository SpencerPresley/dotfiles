# Ghostty ssh-integration opt-out, driven by ~/.ssh/config rather than by memory.
#
# `shell-integration-features = ssh-terminfo` makes Ghostty's shell integration
# define an ssh() function that, before connecting, pipes `infocmp -0 -x
# xterm-ghostty` over a ControlMaster connection and runs `tic -x -` on the far
# end (see $GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration).
# That assumes a POSIX shell over there. Hosts that answer with a vendor CLI
# can't parse it, and on password-auth hosts the probe costs an extra prompt
# before it fails. Mark those hosts in ~/.ssh/config:
#
#   Host idc
#     Tag no-ghostty-ssh
#
# and the wrapper below routes them straight to the ssh binary. `Tag` is a
# client-side-only directive (OpenSSH 8.9+) — nothing reaches the remote — and
# `ssh -G <host>` echoes it back, which is how we read it. Keeping the marker in
# ssh config puts the exemption next to the host definition and makes it cover
# every alias, user@host, and bare IP that resolves to the same block.
#
# Timing: Ghostty defines ssh() from _ghostty_deferred_init, a precmd hook, so it
# lands *after* oh-my-zsh sources this file — there is nothing to wrap yet here.
# We register our own precmd behind Ghostty's and wrap from there. zsh copies the
# hook array before iterating it, so ours still fires on the very first prompt
# even though _ghostty_deferred_init rewrites precmd_functions from inside it.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  _ghostty_ssh_optout_install() {
    precmd_functions=(${precmd_functions:#_ghostty_ssh_optout_install})

    # No ssh() means ssh-env and ssh-terminfo are both off; nothing to do.
    (( $+functions[ssh] )) || return 0

    functions[_ghostty_ssh_wrapped]=$functions[ssh]

    ssh() {
      local ssh_key ssh_value
      while IFS=' ' read -r ssh_key ssh_value; do
        # `Tag a,b` renders as a single `tag a,b` line.
        if [[ "$ssh_key" == "tag" && ",$ssh_value," == *",no-ghostty-ssh,"* ]]; then
          command ssh "$@"
          return
        fi
      done < <(command ssh -G "$@" 2>/dev/null)
      _ghostty_ssh_wrapped "$@"
    }
  }
  typeset -ag precmd_functions
  precmd_functions+=(_ghostty_ssh_optout_install)
fi
