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
    rev = "dc5f88970b9e5dfadd958806123e7a99370144dd";
    sha256 = "dY33Y1rZW1OW8OmHUXi7+BGRNfJXRJflHcp7HkXfCec=";
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
