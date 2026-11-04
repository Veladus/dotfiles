{
  lib,
  stdenv,
  pkgs,
  rpm,
  cpio,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libxkbcommon,
  libGL,
  libsecret,
  libnotify,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  tpm2-tss,
  libusb1,
  coreutils,
  gnugrep,
  gnused,
  findutils,
  bash,
  wrapGAppsHook3,
  gsettings-desktop-schemas,
  adwaita-icon-theme,
  hicolor-icon-theme,
  shared-mime-info,
  librsvg,
  makeDesktopItem,
  symlinkJoin,
  runCommand,
  writeShellScript,
  util-linux,
  procps,

  rpmFile,
  sandboxConfig,
  exe ? "usr/lib/chatgpt/codex-launcher", # path inside the rpm; adjust
}:

let
  # pin: `nix flake metadata github:nixpak/nixpak`, then paste the rev below
  nixpak = builtins.getFlake "github:nixpak/nixpak/3b061c82f9ccb99973154ffced2391535da7b66b";
  mkNixPak = nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  libs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libxkbcommon
    libGL
    libsecret
    libnotify
    nspr
    nss
    pango
    systemd
    vulkan-loader
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    tpm2-tss
    libusb1
  ];

  chatgpt = stdenv.mkDerivation {
    pname = "chatgpt-linux";
    version = "preview";
    src = rpmFile;
    dontUnpack = true;
    nativeBuildInputs = [
      rpm
      cpio
      autoPatchelfHook
      wrapGAppsHook3
      makeWrapper
    ];
    buildInputs = libs ++ [
      gsettings-desktop-schemas
      adwaita-icon-theme
      hicolor-icon-theme
      shared-mime-info
      librsvg
    ];
    runtimeDependencies = libs; # dlopen'd libs
    autoPatchelfIgnoreMissingDeps = [
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libc.musl-x86_64.so.1"
    ];
    dontWrapGApps = true; # we wrap manually below to control PATH and flags
    installPhase = ''
      mkdir -p $out && cd $out
      rpm2cpio $src | cpio -idm
    '';
    postFixup = ''
      makeWrapper $out/${exe} $out/bin/chatgpt \
        --prefix PATH : ${
          lib.makeBinPath (
            [
              coreutils
              gnugrep
              gnused
              findutils
              bash
            ]
            ++ sandboxConfig.tools
          )
        } \
        --add-flags "--enable-logging=stderr" \
        --set XDG_CURRENT_DESKTOP GNOME \
        --set TMPDIR /tmp \
        --set GSETTINGS_BACKEND memory \
        --add-flags "--ozone-platform=wayland" \
        "''${gappsWrapperArgs[@]}" \
        --run '${coreutils}/bin/env -0 > /tmp/.chatgpt-env.$$ && ${coreutils}/bin/mv /tmp/.chatgpt-env.$$ /tmp/chatgpt-sandbox.env'
    '';
    meta.mainProgram = "chatgpt";
  };

  sandboxed = mkNixPak {
    config =
      { sloth, ... }:
      let
        delayedConfig = sandboxConfig.delayed sloth;
      in
      {
        app = {
          package = chatgpt;
          binPath = "bin/chatgpt";
        };
        gpu = {
          enable = true;
          provider = "bundle";
        };
        fonts.enable = true;
        locale.enable = true;
        etc.sslCertificates.enable = true;
        bubblewrap = {
          network = true;
          sockets.wayland = true;
          env.TMPDIR = "/tmp";
          bind.rw = delayedConfig.readwrite;
          bind.ro = delayedConfig.readonly;
        };
      };
  };
  appId = "com.nixpak.ChatgptLinux";

  launcher = writeShellScript "chatgpt-launch" ''
    state="$HOME/.local/share/codex-sandbox"
    log="$state/launcher.log"
    mkdir -p "$state/tmp" "$state/home"
    log() { echo "$(${coreutils}/bin/date +%T) $*" >> "$log"; }

    # main process of a running sandbox (not a --type= helper)
    find_main() {
      local p
      for p in $(${procps}/bin/pgrep -u "$(${coreutils}/bin/id -u)" -f 'usr/lib/chatgpt/ChatGPT'); do
        ${coreutils}/bin/tr '\0' ' ' < "/proc/$p/cmdline" | ${gnugrep}/bin/grep -q -- '--type=' && continue
        echo "$p"; return 0
      done
      return 1
    }

    envfile="$state/tmp/chatgpt-sandbox.env"
    log "launched by: $(${coreutils}/bin/cat /proc/$PPID/comm 2>/dev/null)"

    if pid=$(find_main); then
      log "instance running (pid $pid): joining its sandbox"
      envv=()
      if [ -r "$envfile" ]; then
        while IFS= read -r -d "" kv; do
          [[ "$kv" == [A-Za-z_]*=* ]] && envv+=("$kv")
        done < "$envfile"
      fi
      log "passing ''${#envv[@]} env vars"
      if [ "''${#envv[@]}" -lt 5 ]; then
        log "env snapshot missing or too small: not starting a second sandbox"
        exit 1
      fi
      # run the real binary (the snapshot already contains the wrapper's changes,
      # so going through the wrapper again would duplicate PATH entries)
      ${util-linux}/bin/nsenter --preserve-credentials -t "$pid" \
        --user --mount --pid --ipc --uts -r -w \
        ${coreutils}/bin/env -i "''${envv[@]}" ${chatgpt}/${exe} --ozone-platform=wayland "$@" 2>>"$log"
      rc=$?
      log "nsenter exited with $rc"
      exit $rc
    fi

    log "no instance running: starting sandbox"
    rm -rf "$state"/tmp/.org.chromium.* "$state"/tmp/org.chromium.*
    ${findutils}/bin/find "$state/home" -maxdepth 4 -name 'Singleton*' -delete
    exec ${sandboxed.config.env}/bin/chatgpt "$@"
  '';

  launcherBin = runCommand "chatgpt-launcher" { } ''
    install -Dm755 ${launcher} $out/bin/chatgpt
  '';

  # reuse the rpm's icon theme dir if present (hicolor/.../chatgpt.png)
  icons = runCommand "chatgpt-icons" { } ''
    mkdir -p $out/share
    [ -d ${chatgpt}/usr/share/icons ] && cp -r ${chatgpt}/usr/share/icons $out/share/icons
    [ -d ${chatgpt}/usr/share/pixmaps ] && cp -r ${chatgpt}/usr/share/pixmaps/. $out/share/pixmaps/
  '';

  desktopFile = makeDesktopItem {
    name = appId;
    desktopName = "ChatGPT";
    exec = "${launcherBin}/bin/chatgpt %U";
    icon = "chatgpt"; # resolved via the icons copied below, if the rpm ships any
    startupWMClass = appId;
    categories = [ "Development" ];
  };

in
symlinkJoin {
  name = "chatgpt-sandboxed";
  paths = [
    launcherBin
    icons
    desktopFile
    sandboxed.config.env
  ]; # first wins: our bin/chatgpt shadows nixpak's
}
