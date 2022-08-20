alias zz = zellij

def list-repos [] {
    find-all-repos | get name
}

def find-all-repos [] {
    let paths = (ls ~/repos/ | get name |
        append "~/config")
    $paths | each {|it| [[path name]; [$it (basename $it | str trim)]]} | flatten
}

def z [repo: string@list-repos] {
    let template = open --raw ~/.config/zellij/layouts/repo_template.yaml
    $template |
        str replace '{{session_name}}' $repo -s |
        save /tmp/zellij-repo-layout.yaml --raw

    let wd = (find-all-repos | where name == $repo | get path | get 0)
    cd $wd
    zz --layout /tmp/zellij-repo-layout.yaml
}
