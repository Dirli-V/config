def path-sep [] {
    ":"
}

def venv-path [venv-dir] {
    let venv-path = ([$venv-dir "bin"] | path join)
    ($env.PATH | prepend $venv-path | str collect (path-sep))
}

def venv [venv-dir] {
    let venv-abs-dir = ($venv-dir | path expand)
    let venv-name = ($venv-abs-dir | path basename)
    let old-path = ($env.PATH | str collect (path-sep))
    let new-path = (venv-path $venv-abs-dir)
    {PATH: $new-path,
     VENV_OLD_PATH: $old-path,
     VIRTUAL_ENV: $venv-name}
}

alias pvc = python3.8 -m venv ./venv
alias pva = load-env (venv ./venv)
