module completions {
  def list-processes [] {
    ps | get name | uniq | each { || path basename }
  }

  export extern "killall" [
    process: string@list-processes
  ]
}

use completions *
