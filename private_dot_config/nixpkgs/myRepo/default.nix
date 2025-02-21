{
    pkgs ? import <nixpkgs> {},
    pkgs-unstable ? import <nixpkgs-unstable> {},
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
      libclang = pkgs.llvmPackages_12.libclang;
    };

    bapc-tools = pkgs.callPackage ./bapc.nix {};

#    myTexlive = (pkgs.texlive.combine {
#      inherit (pkgs.texlive)
#        adjustbox
#        algorithm2e
#        biber
#        biblatex
#        blindtext
#        booktabs
#        capt-of
#        caption
#        cleveref
#        collectbox
#        collection-fontsextra
#        collection-fontsrecommended
#        collection-langgerman
#        comment
#        complexity
#        csquotes
#        datetime2
#        enumitem
#        forloop
#        ifoddpage
#        koma-script
#        l3kernel
#        l3packages
#        latexmk
#        marginnote
#        mathtools
#        mdwtools
#        microtype
#        multirow
#        ncctools
#        pdfcomment
#        pdflscape
#        pgf
#        pgfplots
#        relsize
#        scheme-medium
#        setspace
#        siunitx
#        soul
#        soulutf8
#        soulpos
#        thmtools
#        threeparttable
#        tkz-base
#        todonotes
#        urlbst
#        wrapfig
#        xcolor
#        xpatch
#        xstring
#        zref;
#    });
    myTexlive = pkgs.texlive.combined.scheme-full;

    myIpe = pkgs.qt6Packages.callPackage ./ipe.nix {
      texliveSmall = myTexlive;
    };

    myGurobi = pkgs.callPackage ./gurobi.nix {};
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    '');

    inherit
      bapc-tools
      myIpe
      myNeovim
      myTexlive;

    inherit (pkgs.jetbrains) 
      clion;

    inherit (pkgs)
        ccls
        chezmoi
        cmake
        dejavu_fonts
        dotool
        emacs29
        entr
        evince
        fd
        gcc14
        gdb
        graphviz
        htop
        kdotool
        keepassxc
        ninja
        nix-index
        nodejs_22
        okular
        ripgrep
        rustup
        signal-desktop
        slack
        sshpass
        tealdeer
        thunderbird
        tree
        wl-clipboard;


    inherit (pkgs-unstable)
        zig
        zls;
}
