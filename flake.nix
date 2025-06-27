{
  description = "Flake for building HolyC compiler";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "holyc";
        version = "0.1.0";
        src = ./src;

        nativeBuildInputs = [ pkgs.cmake pkgs.makeWrapper ];

        buildPhase = ''
          cmake -S ${src} -B build \
            -DCMAKE_C_COMPILER=${pkgs.stdenv.cc}/bin/cc \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=$out \
            -DCMAKE_C_FLAGS='-Wextra -Wall -Wpedantic -Wno-implicit-fallthrough'

          cmake --build build
          mkdir -p $out/include
          mkdir -p $out/lib
          cp ${src}/holyc-lib/* $out/include
          cp ${src}/holyc-lib/* $PWD
          ./hcc -lib tos ${src}/holyc-lib/all.HC
        '';

        installPhase = ''
          cmake --install build
        '';

        meta = with pkgs.lib; {
          description = "HolyC compiler (from holyc-lang)";
          homepage = "https://github.com/your-org-or-name/holyc-lang";
          license = licenses.mit;
          maintainers = with maintainers; [ ];
          platforms = platforms.linux;
        };
      };
    };
}
