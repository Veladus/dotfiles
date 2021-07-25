{
    pkgs ? import <nixpkgs> {}
}:

let
    myProfile = pkgs.writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:$PATH
    '';

    myNeovim = pkgs.neovim.override {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            ale
            delimitMate
            ultisnips
            vim-fugitive
            vim-nix
            vim-tmux-navigator
            vimtex
          ];
        };
      };
    };
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/my-profile.sh
    '');

    inherit myNeovim;

    inherit (pkgs) 
        chezmoi
        discord
        htop
        ipe
        keepassxc
        rustup
        slack
        sshpass
        tdesktop
        thunderbird
        vscode;
}
