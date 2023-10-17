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

    myIpe = (pkgs.ipe.override { texlive = myTexlive; });
in {
    setupEnv = (pkgs.runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/00-my-profile.sh
    '');

    inherit
      myCf-tool
      #myIpe
      myNeovim
      myTexlive;

    inherit (pkgs.jetbrains) 
      clion;

    inherit (pkgs) 
        chezmoi
        dejavu_fonts
        discord
        emacs
        entr
        fd
        flameshot
        htop
        jq
        keepassxc
        nix-index
        okular
        ripgrep
        rustup
        signal-desktop
        slack
        sshpass
        tealdeer
        thunderbird
        tree
        vscode
        xclip
        xournalpp;
}
