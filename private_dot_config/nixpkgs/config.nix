{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {
    myProfile = writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:$PATH
    '';
	myNeovim = neovim.override {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
			delimitMate
			ultisnips
			vim-fugitive
			vim-tmux-navigator
		    ale
            vimtex
		  ];
        };      
	  };
    };
    myPackages = pkgs.buildEnv {
      name = "my-packages";
      paths = [
        (runCommand "profile" {} ''
          mkdir -p $out/etc/profile.d
          cp ${myProfile} $out/etc/profile.d/my-profile.sh
        '')
	chezmoi
	discord
	htop
	ipe
	keepassxc
	rustup
	slack
	sshpass
	tdesktop
	thunderbird
	vscode
      ];
    };
  };
}

