{
  pkgs ? import <nixpkgs> {},
}:
with pkgs;
buildGoPackage {
  name = "cf-tool";

  src = fetchFromGitHub {
    owner = "xalanq";
    repo = "cf-tool";
    rev = "4aff8682ad0d1e14155c9744a3f27780576bb11e";
    sha256 = "00m2yiaq31i3q4cx1wp6rv8l3p1x11m1r88sffj0x7j0mka3k6wy";
  };

  goPackagePath = "github.com/xalanq/cf-tool";
  # goDeps = ./cf-tool-deps.nix;
}
