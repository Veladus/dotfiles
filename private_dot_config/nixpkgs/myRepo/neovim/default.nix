{
  pkgs ? import <nixpkgs> {}
}:

let
  customRC = builtins.readFile ./init.vim;
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
    inherit customRC;
    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        ale
        delimitMate
        tex-conceal
        ultisnips
        vim-fugitive
        vim-nix
        vim-tmux-navigator
        vimtex
      ];
    };
  };
}
