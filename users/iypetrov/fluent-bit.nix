{ pkgs, lib, ... }:

let
  deps = with pkgs; [
    openssl.dev
    libyaml.dev
    zlib.dev
    systemd.dev
    systemd
    msgpack-c
    postgresql.dev
    nghttp2.dev
    c-ares.dev
    zstd.dev
    sqlite.dev
  ];
in {
  home.packages = deps;
  home.sessionVariables = {
    PKG_CONFIG_PATH = lib.concatMapStringsSep ":" (p: "${p}/lib/pkgconfig") deps;
    CMAKE_PREFIX_PATH = lib.concatStringsSep ":" (map toString deps);
  };
}
