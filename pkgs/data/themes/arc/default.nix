{ lib, stdenv
, fetchFromGitHub
, sassc
, meson
, ninja
, pkg-config
, gtk3
, gnome
, gtk-engine-murrine
, optipng
, inkscape
, cinnamon
}:

stdenv.mkDerivation rec {
  pname = "arc-theme";
  version = "20210412";

  src = fetchFromGitHub {
    owner = "jnsh";
    repo = pname;
    rev = version;
    sha256 = "sha256-P7YZTD5bAWNWepL7qsZZAMf8ujzNbHOj/SLx8Fw3bi4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sassc
    optipng
    inkscape
    gtk3
    gnome.gnome-shell
    cinnamon.cinnamon-common
  ];

  propagatedUserEnvPkgs = [
    gnome.gnome-themes-extra
    gtk-engine-murrine
  ];

  enableParallelBuilding = true;

  preBuild = ''
    # Shut up inkscape's warnings about creating profile directory
    export HOME="$NIX_BUILD_ROOT"
  '';

  mesonFlags = [
    "-Dthemes=cinnamon,gnome-shell,gtk2,gtk3,plank,xfwm"
    "-Dvariants=light,darker,dark,lighter"
    "-Dtransparency=true"
    "-Dcinnamon_version=${cinnamon.cinnamon-common.version}"
    "-Dgnome_shell_version=${lib.elemAt (lib.splitString "-" gnome.gnome-shell.version) 0}"
    "-Dgtk3_version=${gtk3.version}"
    "-Dgnome_shell_resource=false"
  ];

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname} $src/AUTHORS $src/*.md
  '';

  meta = with lib; {
    description = "Flat theme with transparent elements for GTK 3, GTK 2 and Gnome Shell";
    homepage = "https://github.com/jnsh/arc-theme";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ simonvandel romildo ];
  };
}
