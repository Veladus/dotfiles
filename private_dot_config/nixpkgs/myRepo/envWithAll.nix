let
	pkgs = import <nixpkgs> {};
	myRepo = import ./. { inherit pkgs; };
in pkgs.buildEnv {
	name = "myRepoPackages";
	paths = builtins.attrValues myRepo;
}
