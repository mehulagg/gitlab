{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        inputs = import ./default.nix;

      in {
        devShell = pkgs.mkShell {

          buildInputs = with pkgs;
            let
              gitlab-libpg_query = fetchurl {
                url =
                  "https://codeload.github.com/lfittl/libpg_query/tar.gz/10-1.0.3";
                sha256 = "0jfij8apzxsdabl70j42xgd5f3ka1gdcrk764nccp66164gpcchk";
              };
              libpg_query = fetchurl {
                url =
                  "https://codeload.github.com/lfittl/libpg_query/tar.gz/10-1.0.4";
                sha256 = "0f0kshhai0pnkqj0w4kgz3fssnvwidllc31n1fysxjjzdqlr1k48";
              };
              gems = bundlerEnv {
                name = "gems-for-gitlab";
                gemdir = ./.;
                ruby = ruby_2_7;
                ignoreCollisions = true;
                gemConfig = defaultGemConfig // {
                  openssl = attrs: {
                    buildFlags = [ "--with-openssl-dir=${openssl.dev}" ];
                    buildInputs = [ openssl.dev ];
                  };
                  gitlab-pg_query = attrs: {
                    dontBuild = false;
                    postPatch = ''
                      sed -i "s;'https://codeload.github.com/lfittl/libpg_query/tar.gz/' + LIB_PG_QUERY_TAG;'${gitlab-libpg_query}';" ext/pg_query/extconf.rb
                    '';
                  };
                  pg_query = attrs: {
                    dontBuild = false;
                    postPatch = ''
                      sed -i "s;'https://codeload.github.com/lfittl/libpg_query/tar.gz/' + LIB_PG_QUERY_TAG;'${libpg_query}';" ext/pg_query/extconf.rb
                    '';
                  };
                  sassc = attrs: {
                    nativeBuildInputs = [ rake ];
                    dontBuild = false;
                    SASS_LIBSASS_PATH = toString libsass;
                    postPatch = ''
                      substituteInPlace lib/sassc/native.rb \
                        --replace 'gem_root = spec.gem_dir' 'gem_root = File.join(__dir__, "../../")'
                    '';
                  };
                  grpc = attrs: {
                    nativeBuildInputs = [ pkg-config ]
                      ++ pkgs.lib.optional pkgs.stdenv.isDarwin darwin.cctools;
                    buildInputs = [ openssl ];
                    hardeningDisable = [ "format" ];
                    NIX_CFLAGS_COMPILE = toString [
                      "-Wno-error=stringop-overflow"
                      "-Wno-error=implicit-fallthrough"
                      "-Wno-error=sizeof-pointer-memaccess"
                      "-Wno-error=cast-function-type"
                      "-Wno-error=class-memaccess"
                      "-Wno-error=ignored-qualifiers"
                      "-Wno-error=tautological-compare"
                      "-Wno-error=stringop-truncation"
                    ];
                    dontBuild = false;
                    postPatch = ''
                      substituteInPlace Makefile \
                        --replace '-Wno-invalid-source-encoding' ""
                    '';
                  };

                };
              };

            in [
              binutils
              icu
              cmake
              gcc
              re2
              krb5
              sqlite
              readline
              zlib
              pkg-config
              graphicsmagick
              exiftool
              openssl
              pcre2
              curl
              tzdata
              gems

              (ruby_2_7.withPackages (ps: with ps; [ bundler ]))
              yarn
              nodejs-14_x
            ];
        };
      });
}
