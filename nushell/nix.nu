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

# Enter a nix dev shell via direnv/nix-direnv so the evaluated shell is cached.
#
# The .envrc lives in $nu.cache-dir/nd/<hash of flake ref>, never in the repo, so no
# project gets polluted with .envrc/.direnv. `direnv exec` loads that .envrc but
# runs the command in the *current* directory.
def nd-enter [flake_ref: string] {
  let cache = ($nu.cache-dir | path join "nd" ($flake_ref | hash sha256))
  let envrc = ($cache | path join ".envrc")
  let content = $"use flake ($flake_ref)\n"
  if not (($envrc | path exists) and ((open --raw $envrc) == $content)) {
    mkdir $cache
    $content | save -f $envrc
    direnv allow $cache
  }
  # nix-direnv keeps its gcroot next to the .envrc, so the dev shell also
  # survives `nix store gc` -- unlike a plain `nix develop`.
  direnv exec $cache nu
}

def use_cwd_flake_if_exists [] {
  if ("./flake.nix" | path exists) {
    nd-enter (pwd)
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
    nd-enter (if ($name | is-empty) { $flake_path } else { $"($flake_path)#($name)" })
  } else if not $silent {
    nd-enter (pwd)
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
