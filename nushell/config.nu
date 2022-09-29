let-env config = {
    edit_mode: vi,
    shell_integration: true,
    show_banner: false,
}

let-env PROMPT_COMMAND = { starship prompt }
let-env PROMPT_COMMAND_RIGHT = ""
let-env JAVA_HOME = "/usr/lib/jvm/default"
let-env PATH = ($env.PATH | append ("~" | path expand | path join ".cargo/bin"))

source ~/.config/nushell/paru.nu
source ~/.config/nushell/git.nu
source ~/.config/nushell/venv.nu
source ~/.config/nushell/zellij.nu
source ~/.config/nushell/xplr.nu
source ~/.config/nushell/bluetooth.nu
source ~/.config/nushell/systemd.nu
source ~/.config/nushell/cerebro.nu
source ~/personal_config/scripts/config.nu
