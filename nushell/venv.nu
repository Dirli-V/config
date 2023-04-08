def path-sep [] {
    ":"
}

def venv-path [venv_dir] {
    let venv_path = ([$venv_dir "bin"] | path join)
    ($env.PATH | prepend $venv_path | str join (path-sep))
}

def venv [venv_dir] {
    let venv_abs_dir = ($venv_dir | path expand)
    let venv_name = ($venv_abs_dir | path basename)
    let old_path = ($env.PATH | str join (path-sep))
    let new_path = (venv-path $venv_abs_dir)
    {PATH: $new_path,
     VENV_OLD_PATH: $old_path,
     VIRTUAL_ENV: $venv_name}
}

alias pvc = python3.8 -m venv ./venv
alias pva = load-env (venv ./venv)
