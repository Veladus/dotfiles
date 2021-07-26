{
  pkgs ? import <nixpkgs> {}
}:

let
  customRC = ./init.vim;

  libClang = pkgs.libclang.lib;

  cppStdLibProvider = pkgs.gcc-unwrapped;
  cppStdLib = pkgs.runCommandNoCC "cppStdLib-headers" {} ''
    INCLUDE_DIR=$out/${cppStdLibProvider.version}/include

    mkdir -p $INCLUDE_DIR
    ${pkgs.xorg.lndir}/bin/lndir -silent ${cppStdLibProvider}/include/c++/${cppStdLibProvider.version}/ $INCLUDE_DIR
    ${pkgs.xorg.lndir}/bin/lndir -silent ${cppStdLibProvider}/include/c++/${cppStdLibProvider.version}/x86_64-unknown-linux-gnu/ $INCLUDE_DIR
    '';

  tex-conceal = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tex-conceal";
    src = pkgs.fetchFromGitHub {
      owner = "KeitaNakamura";
      repo = "tex-conceal.vim";
      rev = "822712d80b4ad5bc5c241ab0a778ede812ec501f";
      sha256 = "1gcf2afx0h9z4n6hhw625bzzll7m7knydc2qcm728nvn9d1ch3wn";
    };
  };

in pkgs.neovim.override {
  configure = {
    customRC = ''
      source ${customRC}

      " Set libclang paths for deoplete
      let g:deoplete#sources#clang#clang_header="${cppStdLib}"
      let g:deoplete#sources#clang#libclang_path="${libClang}/lib/libclang.so"
    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        ale
        delimitMate
        deoplete-nvim
        tex-conceal
        ultisnips
        vim-fugitive
        vim-nix
        vim-tmux-navigator
        vimtex
      ];

      opt = [
        deoplete-clang
      ];
    };
  };
}
