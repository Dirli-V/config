ln -s ~/config/.tmux.conf ~/.tmux.conf
ln -s ~/config/nvim ~/.config
ln -s ~/config/nushell ~/.config
ln -s ~/config/zellij ~/.config/zellij
ln -s ~/config/starship.toml ~/.config
ln -s ~/config/window_mover.yaml ~/.config/window_mover.yaml
ln -s ~/config/cspell ~/.config/cspell
ln -s ~/config/codespell ~/.config/codespell
ln -s ~/config/qutebrowser/ ~/.config
as make
as xclip
as xdotool
as wmctrl
as tmux
as zellij
as neovim
as jre-openjdk
as rust-analyzer
as cargo-nextest
as lldb
as libffi
as ripgrep
as fd
as texlive-bin
as stylua
as fzf
as npm
as python
as python-pip
as icu
as unzip
as xplr
as just
as nerd-fonts-fira-code
as noto-fonts-emoji
as bandwhich
as unclutter-xfixes-git
as docker
as qutebrowser
as python-adblock
sudo usermod -aG docker $env.USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
as k9s
sudo npm install -g cspell
sudo npm install -g jsonlint
sudo npm install -g stylelint
sudo npm install -g vscode-json-languageserver
pip install proselint
pip install autopep8
as codespell
as wezterm-nightly-bin
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git config --global core.editor "nvim"
git config --global push.autoSetupRemote true
git config --global init.defaultBranch main
mkdir ~/.config/systemd/user
ln -s ~/config/unclutter.service ~/.config/systemd/user/unclutter.service
systemctl --user enable unclutter.service
systemctl --user start unclutter.service
python -m venv ~/debugpy
~/debugpy/bin/pip install debugpy
cargo install cargo-update
cargo install inlyne
