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

    myCf-tool = pkgs.callPackage ./cf-tool.nix {};
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    '');

    inherit
      myCf-tool
      myNeovim;

    inherit (pkgs.jetbrains) 
      clion;

    inherit (pkgs) 
        chezmoi
        discord
        elan
        entr
        htop
        ipe
        keepassxc
        nix-index
        okular
        mathlibtools
        ripgrep
        rustup
        signal-desktop
        slack
        sshpass
        tdesktop
        tealdeer
        thunderbird
        tree
        vscode
        xournalpp;
}
