$env.config = {
    edit_mode: vi,
    show_banner: false,
    highlight_resolved_externals: true,
    color_config: {
        # Ember/WezTerm map ANSI bright-black to the terminal background; Nushell
        # uses dark_gray for inline completion hints, so override with a muted fg.
        hints: "#908a7e",
    },
    menus: [
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0
                max_completion_width: 50
                max_completion_height: 10
                padding: 0
                border: true
                cursor_offset: 0
                description_mode: prefer_right
                min_description_width: 15
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                correct_cursor_pos: false
            }
            style: {
                text: "#d8d0c0"
                selected_text: { fg: "#1c1b19", bg: "#e08060" }
                description_text: "#908a7e"
                match_text: { fg: "#c8b468", attr: u }
                selected_match_text: { fg: "#1c1b19", bg: "#e08060", attr: u }
            }
        }
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
                tab_traversal: horizontal
            }
            style: {
                text: "#d8d0c0"
                selected_text: { fg: "#1c1b19", bg: "#e08060" }
                description_text: "#908a7e"
            }
        }
    ],
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

source ~/.config/nushell/git.nu
source ~/.config/nushell/bluetooth.nu
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
