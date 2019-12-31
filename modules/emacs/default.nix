{ pkgs, ... }:

let
  used-packages = import (
    pkgs.runCommand "used-packages" rec {
      emacs = pkgs.emacsWithPackages (epkgs: [ epkgs.use-package ]);
      buildInputs = [ emacs ];
      srcs = [ ./used-packages.el ./init.el ];
    } ''
      mkdir -p $out
      emacs --batch -l ${./used-packages.el} --eval '(ross/used-packages "${./init.el}")' > $out/default.nix
    ''
  );

  # Things we want to ensure are on the exec-path.
  extraSystemPackages = with pkgs; [
    fd
    git
    ripgrep
  ];
in
{
  home.file = {
    ".emacs.d/custom.el".source = ./custom.el;
    ".emacs.d/init.el".source = ./init.el;
  };

  home.packages = [ pkgs.emacs-all-the-icons-fonts ];

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: (used-packages epkgs) ++ extraSystemPackages;

    overrides = self: super:
      let
        inherit (pkgs) fetchFromGitHub fetchurl stdenv;
        inherit (stdenv) lib;

        withPatches = pkg: patches:
          lib.overrideDerivation pkg (attrs: { inherit patches; });
      in
        {
          git-gutter = withPatches super.git-gutter [ ./patches/git-gutter.patch ];
          lsp-mode = self.melpaBuild {
            pname = "lsp-mode";
            version = "20190723.2001";
            src = fetchFromGitHub {
              owner = "emacs-lsp";
              repo = "lsp-mode";
              rev = "614e33450c8a6faf3d72502eb44cee4412663f4a";
              sha256 = "05qm1dk26426gpbcjcqzzs05fxi7js0g0fifvaxj0gm4pndizbi2";
            };
            recipe = fetchurl {
              url = "https://raw.githubusercontent.com/milkypostman/melpa/51a19a251c879a566d4ae451d94fcb35e38a478b/recipes/lsp-mode";
              sha256 = "0cklwllqxzsvs4wvvvsc1pqpmp9w99m8wimpby6v6wlijfg6y1m9";
              name = "lsp-mode";
            };
            packageRequires = with self; [ dash dash-functional emacs f ht markdown-mode spinner ];
            meta = {
              homepage = "https://melpa.org/#/lsp-mode";
              license = lib.licenses.free;
            };
          };
          quick-yes =
            let
              version = "10";
            in
              stdenv.mkDerivation {
                inherit version;
                name = "quick-yes-${version}";
                src = ./quick-yes;
                installPhase = ''
                  mkdir -p $out/share/emacs/site-lisp
                  cp *.el $out/share/emacs/site-lisp/
                '';
              };
          sbt-mode = withPatches super.sbt-mode [
            ./patches/sbt-mode/e9aa908d1b80dc2618eab22eeefc68ae82d0026f.patch
          ];
          snow =
            let
              rev = "8a8159f0faf6db7f17ce40f650592d55541e348b";
            in
              stdenv.mkDerivation rec {
                version = rev;
                name = "snow-${version}";
                src = fetchFromGitHub {
                  inherit rev;
                  owner = "alphapapa";
                  repo = "snow.el";
                  sha256 = "0s55yqn3gyl2607aar7qj11hf9pgn7y2kngm6b1myg6lp885b06h";
                };
                installPhase = ''
                  mkdir -p $out/share/emacs/site-lisp
                  cp *.el $out/share/emacs/site-lisp/
                '';
              };
          title-capitalization =
            let
              version = "0.1";
            in
              stdenv.mkDerivation {
                inherit version;
                name = "title-capitalization-${version}";
                src = fetchFromGitHub {
                  owner = "novoid";
                  repo = "title-capitalization.el";
                  rev = "e83d463c500d04adf47b2e444728803121e7b641";
                  sha256 = "0y0fhi8sb3chh5pzgn0rp7cy7492bw5yh1dldmpqxcsykjn06aga";
                };
                installPhase = ''
                  mkdir -p $out/share/emacs/site-lisp
                  cp *.el $out/share/emacs/site-lisp/
                '';
              };
          vterm = super.emacs-libvterm;
        };
  };
}
