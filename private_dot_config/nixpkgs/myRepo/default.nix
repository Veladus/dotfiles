{
  pkgs ? import <nixpkgs> { },
  # pkgs-unstable ? import <nixpkgs-unstable> { },
}:

let
  myProfile = pkgs.writeText "my-profile" ''
    export MANPATH=":"
    export PATH="$HOME/.cargo/bin:$PATH"
    export CPATH="$HOME/.nix-profile/include:$CPATH"
    export LIBRARY_PATH="$HOME/.nix-profile/lib:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$HOME/.nix-profile/lib:$LD_LIBRARY_PATH"
  '';

  myNeovim = pkgs.callPackage ./neovim {
    libclang = pkgs.libclang;
  };

  bapc-tools = pkgs.callPackage ./bapc.nix { };

  myTexlive = pkgs.texliveFull;

  myIpe = pkgs.qt6Packages.callPackage ./ipe.nix {
    lua5 = pkgs.lua5_4_compat;
    texliveSmall = myTexlive;
  };

  myGurobi = pkgs.callPackage ./gurobi.nix { };

  myVsCode = pkgs.vscode-with-extensions.override {
    vscodeExtensions =
      with pkgs.vscode-extensions;
      [
        asvetliakov.vscode-neovim
        tamasfe.even-better-toml
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "lean4";
          publisher = "leanprover";
          version = "0.0.239";
          sha256 = "6XqjmClUzmyz1nkp/bLv5+F9cj7ZCp4+uAGIJgLDi+o=";
        }
      ];
  };

  mySage = (pkgs.sage.override { requireSageTests = false; });
in
{
  setupEnv = (
    pkgs.runCommand "profile" { } ''
      mkdir -p $out/etc/profile.d
      cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    ''
  );

  inherit
    bapc-tools
    myIpe
    myNeovim
    mySage
    myTexlive
    myVsCode
    ;

  inherit (pkgs.llvmPackages) libstdcxxClang;

  inherit (pkgs.jetbrains) clion;

  inherit (pkgs)
    ccls
    chezmoi
    cmake
    dejavu_fonts
    dotool
    elan
    emacs
    entr
    evince
    fd
    gdb
    graphviz
    htop
    keepassxc
    ninja
    nix-index
    nixfmt
    nodejs_22
    proton-pass
    # protonvpn-gui
    ripgrep
    rustup
    signal-desktop
    sshpass
    tealdeer
    thunderbird
    tree
    wl-clipboard
    zotero
    ;

  #  inherit (pkgs-unstable)
  #    zig
  #    zls
  #    ;
}
