alias nr = sudo nixos-rebuild switch
alias ncu = sudo nix-channel --update
alias nn = (ncu; nr)
alias nfu = nix flake update
alias nfua = (fd flake.nix ~/personal_config/ |
  lines |
  each {|it| nix flake update (echo $it | path dirname) | echo "✔ " $it | str join })

def nd [name = ""] {
    if ("./flake.nix" | path exists) {
        nix develop
        return
    }
    let repo_path = (git rev-parse --show-toplevel)
    let repo_name = (echo $repo_path | path basename)
    let path = (echo (pwd) | path relative-to $repo_path)
    nix develop (echo ("~/personal_config/flakes" | path join $repo_name | path join $path) "#" $name | str join)
}
