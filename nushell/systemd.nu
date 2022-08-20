alias ll = ls -l
alias sc = systemctl
alias ssc = sudo sc
alias sl = journalctl

module completions {
  def list-commands [] {
    echo [
      "status"
      "enable"
      "disable"
      "start"
      "stop"
      "list-units"
    ]
  }

  def convert-units [] {
    lines | skip 1 | reverse | skip 6 | reverse | each { |it|
      $it | split row " " | get 0
    }
  }

  def list-units [] {
    (echo
      (systemctl --user list-units --type=service | convert-units)
      (systemctl list-units --type=service | convert-units)) |
      flatten
  }

  export extern "systemctl" [
    command: string@list-commands
    ...units: string@list-units
    --user
    --type=service
  ]

  export extern "sudo sc" [
    command: string@list-commands
    ...units: string@list-units
  ]
}

use completions *
