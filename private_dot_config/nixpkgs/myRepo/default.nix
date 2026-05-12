{
  pkgs ? import <nixpkgs> { },
  pkgs-unstable ? import <nixpkgs-unstable> { },
}:

let
  myProfile = pkgs.writeText "my-profile" ''
    export MANPATH=":"
    export PATH="$PATH:$HOME/.cargo/bin"
    export CPATH="$CPATH:$HOME/.nix-profile/include"
    export LIBRARY_PATH="$LIBRARY_PATH:$HOME/.nix-profile/lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.nix-profile/lib"
  '';

  myNeovim = pkgs.callPackage ./neovim {
    libclang = pkgs.libclang;
  };

  bapc-tools = pkgs.callPackage ./bapc.nix { };

  myTexlive = pkgs.texlive.combined.scheme-full;

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
          version = "0.0.211";
          sha256 = "BoziDTMxM2ffel/3/lD9zf0M7//li1XRcuAUgnbS2o4=";
        }
      ];
  };
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
    myTexlive
    myVsCode
    ;

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
    gcc14
    gdb
    graphviz
    htop
    keepassxc
    ninja
    nix-index
    nixfmt-rfc-style
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

  inherit (pkgs-unstable)
    zig
    zls
    ;
}
