alias a = paru
alias as = paru -S
def aall [] {
  paru -Syu
  sudo snap refresh
  flatpack update
}
