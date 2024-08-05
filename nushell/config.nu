$env.config = {
    edit_mode: vi,
    shell_integration: true,
    show_banner: false,
    highlight_resolved_externals: true,
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
