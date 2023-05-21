alias nr = sudo nixos-rebuild switch
alias ncu = sudo nix-channel --update
def nn [] {
  ncu
  nr
}
alias nsp = nix-shell -p
alias nfu = nix flake update
def nfua [] {
  fd flake.nix ~/personal_config/ |
  lines |
  each {|it| nix flake update (echo $it | path dirname) | echo "✔ " $it | str join }
}

def nd [name = ""] {
    if ("./flake.nix" | path exists) {
        nix develop
        return
    }
    let repo_path = (git rev-parse --show-toplevel)
    let repo_name = (echo $repo_path | path basename)
    let path = (echo (pwd) | path relative-to $repo_path)
    let flake_path = ("~/personal_config/flakes" | path join $repo_name | path join $path | path expand)
    nix develop (echo $flake_path "#" $name | str join)
}
