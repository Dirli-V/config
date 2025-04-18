alias nfu = nix flake update
def nr [] {
  sudo nixos-rebuild switch --flake $"($env.HOME)/personal_config/nixos#(hostname)"
}
def nn [] {
  cd ~/config
  nfu ./nixos
  nr
}
alias nsp = nix-shell -p
def nfua [] {
  fd flake.nix ~/personal_config/ |
  lines |
  each {|it|
    let path = (echo $it | path dirname)
    nix flake update --flake $path
    # let message = (echo "echo" "✔ " $it | str join)
    # nix develop $path --command $message
  }
}

def use_cwd_flake_if_exists [] {
  if ("./flake.nix" | path exists) {
    nix develop --command nu
  }
}

def nd [name = "", --silent] {
  if (do { git rev-parse --is-inside-work-tree } | complete | get exit_code) == 128 {
    use_cwd_flake_if_exists
    return
  }
  let repo_path = (git rev-parse --show-toplevel)
  let repo_name = (echo $repo_path | path basename)
  let path = (echo (pwd) | path relative-to $repo_path)
  let flake_path = ("~/personal_config/flakes" | path join $repo_name | path join $path | path expand)
  if ($flake_path | path join "flake.nix" | path exists) {
    nix develop (echo $flake_path "#" $name | str join) --command nu
  } else if not $silent {
    nix develop --command nu
  } else {
    use_cwd_flake_if_exists
  }
}

def download_nixpkgs_cache_index [] {
  let filename = $"index-(uname | get machine | sed 's/^arm64$/aarch64/')-(uname | get kernel-name | tr A-Z a-z)"
  mkdir ~/.cache/nix-index
  cd ~/.cache/nix-index
  wget -q -N $"https://github.com/Mic92/nix-index-database/releases/latest/download/($filename)"
  ln -f $filename files
}

alias nl = nix-locate
alias nlt = nix-locate --top-level
