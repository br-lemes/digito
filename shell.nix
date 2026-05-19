with import <nixpkgs> { };

mkShell {
  buildInputs = [ gtk3 ];
  nativeBuildInputs = [
    gh
    git
    gnumake
    go
    openssh
    pkg-config
    pkgsCross.mingwW64.stdenv.cc
  ];
}
