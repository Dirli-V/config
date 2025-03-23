$env.config = {
    edit_mode: vi,
    show_banner: false,
    highlight_resolved_externals: true,
    keybindings: [
        {
            name: insert-path
            modifier: control
            keycode: char_f
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert (fzf)"
            }
        }
        {
            name: insert-directory
            modifier: control
            keycode: char_x
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert (x)"
            }
        }
        {
            name: complete-word
            modifier: control
            keycode: char_j
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: HistoryHintWordComplete
            }
        }
        {
            name: complete-line
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: HistoryHintComplete }
                    { send: ClearScreen }
                ]
            }
        }
    ]
}

source ~/.config/nushell/paru.nu
source ~/.config/nushell/git.nu
source ~/.config/nushell/venv.nu
source ~/.config/nushell/zellij.nu
source ~/.config/nushell/xplr.nu
source ~/.config/nushell/bluetooth.nu
source ~/.config/nushell/systemd.nu
source ~/.config/nushell/cerebro.nu
source ~/.config/nushell/cargo.nu
source ~/.config/nushell/nix.nu
source ~/.config/nushell/zoxide.nu
source ~/.config/nushell/killall.nu
source ~/.config/nushell/atuin.nu
source ~/.config/nushell/atuin_completion.nu
source ~/personal_config/scripts/config.nu

alias ssh = env TERM=xterm ssh
def background [cmd: string] {
    sh -c $"($cmd) &"
}
alias '&' = background
alias fg = job unfreeze
