alias a = paru
alias as = paru -S
alias ar = paru -Rns
def aall [] {
  paru -Syu
  sudo snap refresh
  flatpak update
  cargo install-update -a
  sudo npm update -g
}
