{
    pkgs ? import <nixpkgs> {}
}:

let
    myProfile = pkgs.writeText "my-profile" ''
      export MANPATH=":"
    '';

    myNeovim = pkgs.callPackage ./neovim {
      libclang = pkgs.llvmPackages_12.libclang;
    };
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    '');

    inherit
      myNeovim;

    inherit (pkgs) 
        chezmoi
        discord
        htop
        ipe
        keepassxc
        nix-index
        ripgrep
        rustup
        slack
        sshpass
        tdesktop
        tealdeer
        thunderbird
        tree
        vscode;
}
