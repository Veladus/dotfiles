{ fetchFromGitHub,
  stdenv,

  findutils,
  gawk,
  python3,
}:

let
  python-env = python3.withPackages (ps: with ps; [
    argcomplete
    colorama
    matplotlib
    pyyaml
    questionary
    requests
    ruamel-yaml
  ]);
  shebang = "#!${python-env}/bin/python3";
in stdenv.mkDerivation {
  name = "bapc-tools";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "RagnarGrootKoerkamp";
    repo = "BAPCtools";
    rev = "a1f33f323b4a3ced6accc8f0594f5338899258ac";
    sha256 = "1g2krfsy4ql64qwm3ibcbpbpvkjwgbfl6gfq2g6x45i167cqbx75";
  };


  nativeBuildInputs = [findutils gawk];
  buildInputs = [python-env];

  buildPhase = ''
    find . -type f -name "*.py" -exec awk 'NR==1 {if (/^#!/) {$0 = "${shebang}"} else {$0 = "${shebang}\n"}} 1' {} \;
  '';
  installPhase = ''
    mkdir -p $out $out/bin $out/base
    cp -r * $out/base
    ln -s $out/base/bin/tools.py $out/bin/bt
  '';
}
