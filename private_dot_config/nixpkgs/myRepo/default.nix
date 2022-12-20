{
    pkgs ? import <nixpkgs> {}
}:

let
    myProfile = pkgs.writeText "my-profile" ''
      export MANPATH=":"
      export PATH="$PATH:$HOME/.cargo/bin"
    '';

    myNeovim = pkgs.callPackage ./neovim {
      libclang = pkgs.llvmPackages_12.libclang;
    };

    myCf-tool = pkgs.callPackage ./cf-tool.nix {};

#    myTexlive = (pkgs.texlive.combine {
#      inherit (pkgs.texlive)
#        scheme-context;
#    });
    myTexlive = pkgs.texlive.combined.scheme-context;

    myIpe = (pkgs.ipe.override { texlive = myTexlive; });
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    '');

    inherit
      myCf-tool
      myNeovim
      myIpe;

    inherit (pkgs.jetbrains) 
      clion;

    inherit (pkgs) 
        chezmoi
        cmake
        dejavu_fonts
        discord
        elan
        entr
        fd
        htop
        jq
        keepassxc
        nix-index
        okular
        pkg-config
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
