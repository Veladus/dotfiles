{
  fetchFromGitHub,
  runCommandLocal,
  symlinkJoin,

  gcc-unwrapped,
  libclang,
  neovim,
  python3,
  vimUtils,
  vimPlugins,
}:

let
  customRC = ./init.vim;

  # CPP completion
  clangLibraryProvider = libclang.lib;

  cppStdLibProvider = gcc-unwrapped;
  cppStdLibUnwrapped = symlinkJoin {
    name = "cppStdLib-headers-unwrapped";
    paths = [
      "${cppStdLibProvider}/include/c++/${cppStdLibProvider.version}/"
      "${cppStdLibProvider}/include/c++/${cppStdLibProvider.version}/x86_64-unknown-linux-gnu/"
    ];
  };
  cppStdLib = runCommandLocal "cppStdLib-headers" {} ''
    OUTER=$out/${cppStdLibProvider.version}

    mkdir -p $OUTER
    ln -s ${cppStdLibUnwrapped} $OUTER/include
    '';

  # Python completion
  innerPyton = python3.withPackages (pypacks: with pypacks; [
    pynvim
    jedi
  ]);

  # Tex concealing
  tex-conceal = vimUtils.buildVimPlugin {
    name = "vim-tex-conceal";
    src = fetchFromGitHub {
      owner = "KeitaNakamura";
      repo = "tex-conceal.vim";
      rev = "822712d80b4ad5bc5c241ab0a778ede812ec501f";
      sha256 = "1gcf2afx0h9z4n6hhw625bzzll7m7knydc2qcm728nvn9d1ch3wn";
    };
  };


in neovim.override {
  configure = {
    customRC = ''
      source ${customRC}

      " Set libclang paths for deoplete
      let g:deoplete#sources#clang#clang_header="${cppStdLib}"
      let g:deoplete#sources#clang#libclang_path="${clangLibraryProvider}/lib/libclang.so"

      " Set python path for deoplete jedi
      let g:python3_host_prog = "${innerPyton}/bin/python"
    '';

    packages.myVimPackage = with vimPlugins; {
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
        deoplete-jedi
      ];
    };
  };
}
