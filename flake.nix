{
  description = "Python environment managed with mach-nix and flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    mach-nix = {
      url = "github:DavHau/mach-nix";
    };

  };
  outputs = { nixpkgs, flake-utils, mach-nix, ...}:

  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };

    # Do NOT use import mach-nix {inherit system;};
    #
    # otherwise mach-nix will not use flakes and pypi-deps-db
    # input will not be used:
    # https://github.com/DavHau/mach-nix/issues/269#issuecomment-841824763
    mach = mach-nix.lib.${system};

    python-env = mach.mkPython {
      # Choose python version
      python = "python310";

      # Specify python requirements, you can use ./requirements.txt a
      # string (or a combination of both)
      requirements = ''
        ipython
        python-lsp-server
        python-language-server[all]
      '' + (builtins.readFile ./requirements.txt);
    };

  in
  {
    devShell = pkgs.mkShell rec {
      name = "python";
      buildInputs = [ python-env ] ++ (with pkgs; [ opencc ]);

      shellHook = ''
        export DYLD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
        export DYLD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
        export DYLD_LIBRARY_PATH="${pkgs.opencc}/lib:$LD_LIBRARY_PATH"
      '';
    };
  });
}
