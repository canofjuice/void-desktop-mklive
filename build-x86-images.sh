#!/bin/sh

set -eu

. ./lib.sh

PROGNAME=$(basename "$0")
ARCH=$(uname -m)
IMAGES="base"
TRIPLET=
REPO=
DATE=$(date -u +%Y%m%d)

usage() {
	cat <<-EOH
	Usage: $PROGNAME [options ...] [-- mklive options ...]

	Wrapper script around mklive.sh for several standard flavors of live images.
	Adds void-installer and other helpful utilities to the generated images.

	OPTIONS
	 -a <arch>     Set XBPS_ARCH in the image
	 -b <variant>  void-desktop-lite, void-desktop-full. May be specified multiple times
	               to build multiple variants
	 -d <date>     Override the datestamp on the generated image (YYYYMMDD format)
	 -t <arch-date-variant>
	               Equivalent to setting -a, -b, and -d
	 -r <repo>     Use this XBPS repository. May be specified multiple times
	 -h            Show this help and exit
	 -V            Show version and exit

	Other options can be passed directly to mklive.sh by specifying them after the --.
	See mklive.sh -h for more details.
	EOH
}

while getopts "a:b:d:t:hr:V" opt; do
case $opt in
    a) ARCH="$OPTARG";;
    b) IMAGES="$OPTARG";;
    d) DATE="$OPTARG";;
    r) REPO="-r $OPTARG $REPO";;
    t) TRIPLET="$OPTARG";;
    V) version; exit 0;;
    h) usage; exit 0;;
    *) usage >&2; exit 1;;
esac
done
shift $((OPTIND - 1))

INCLUDEDIR=include
trap "cleanup" INT TERM

cleanup() {
    rm -rf "$INCLUDEDIR"/usr/bin/void-installer
    rm -rf "$INCLUDEDIR"/etc/alsa
    rm -rf "$INCLUDEDIR"/etc/pipewire
    rm -rf "$INCLUDEDIR"/etc/xdg/autostart/pipewire.desktop
    echo "penis blast!! :3"
}

setup_pipewire() {
    PKGS="$PKGS pipewire alsa-pipewire"
    mkdir -p "$INCLUDEDIR"/etc/xdg/autostart
    ln -sf /usr/share/applications/pipewire.desktop "$INCLUDEDIR"/etc/xdg/autostart/
    mkdir -p "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d
    ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    mkdir -p "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf "$INCLUDEDIR"/etc/alsa/conf.d
}

build_variant() {
    variant="$1"
    shift
    IMG=void-live-${ARCH}-${DATE}-${variant}.iso
    GRUB_PKGS="grub-i386-efi grub-x86_64-efi"
    A11Y_PKGS="espeakup void-live-audio brltty"
    PKGS="dialog cryptsetup lvm2 smartmontools mdadm void-docs-browse xtools-minimal xmirror void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree chrony 7zip xz unzip unrar wget nano dosfstools ntfs-3g exfatprogs ufw tlp $A11Y_PKGS $GRUB_PKGS"
    XORG_PKGS="xorg-minimal xorg-input-drivers xorg-video-drivers setxkbmap xauth font-misc-misc terminus-font dejavu-fonts-ttf noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji noto-fonts-ttf-extra cantarell-fonts gparted gnome-disk-utility onboard orca"
    SERVICES="sshd chronyd ufw tlp"

    LIGHTDM_SESSION=''

    case $variant in
#        base)
#            SERVICES="$SERVICES dhcpcd wpa_supplicant acpid"
#        ;;
        void-desktop-base)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter xfce4 gnome-themes-standard xcursor-vanilla-dmz gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox xfce4-screenshooter greybird-themes galculator pavucontrol xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-weather-plugin xfce4-xkb-plugin adwaita-qt adwaita-qt6 engrampa xreader octoxbps menulibre xdg-desktop-portal-gtk gufw bluez blueman libspa-bluetooth"
            SERVICES="$SERVICES dbus lightdm NetworkManager polkitd bluetoothd"
            LIGHTDM_SESSION=xfce
            TYPE="(Base)"
        ;;
        void-desktop-lite)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter xfce4 gnome-themes-standard xcursor-vanilla-dmz gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox xfce4-screenshooter greybird-themes galculator pavucontrol xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-weather-plugin xfce4-xkb-plugin adwaita-qt adwaita-qt6 engrampa xreader abiword gnumeric evolution gimp shortwave octoxbps menulibre xdg-desktop-portal-gtk gufw bluez blueman libspa-bluetooth"
            SERVICES="$SERVICES dbus lightdm NetworkManager polkitd bluetoothd"
            LIGHTDM_SESSION=xfce
            TYPE="(Lite)"
        ;;
        void-desktop-full)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter xfce4 gnome-themes-standard xcursor-vanilla-dmz gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox xfce4-screenshooter greybird-themes galculator pavucontrol xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-weather-plugin xfce4-xkb-plugin adwaita-qt adwaita-qt6 engrampa xreader libreoffice thunderbird keepassxc gimp inkscape ssr kdenlive shortwave aisleriot quadrapassel gnome-mahjongg gnome-mines gnome-chess gnome-sudoku iagno octoxbps menulibre xdg-desktop-portal-gtk gufw bluez blueman libspa-bluetooth"
            SERVICES="$SERVICES dbus lightdm NetworkManager polkitd bluetoothd"
            LIGHTDM_SESSION=xfce
            TYPE="(Full)"
        ;;
        *)
            >&2 echo "Unknown variant $variant"
            exit 1
        ;;
    esac

    if [ -n "$LIGHTDM_SESSION" ]; then
        mkdir -p "$INCLUDEDIR"/etc/lightdm
        echo "$LIGHTDM_SESSION" > "$INCLUDEDIR"/etc/lightdm/.session
        # needed to show the keyboard layout menu on the login screen
        cat <<- EOF > "$INCLUDEDIR"/etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
indicators = ~host;~spacer;~clock;~spacer;~layout;~session;~a11y;~power
EOF
    fi

    if [ "$variant" != base ]; then
        setup_pipewire
    fi

    ./mklive.sh -T "Void Desktop $TYPE" -a "$ARCH" -o "$IMG" -p "$PKGS" -S "$SERVICES" -I "$INCLUDEDIR" ${REPO} "$@"

	cleanup
}

if [ ! -x mklive.sh ]; then
    echo mklive.sh not found >&2
    exit 1
fi

if [ -x installer.sh ]; then
    MKLIVE_VERSION="$(PROGNAME='' version)"
    installer=$(mktemp)
    sed "s/@@MKLIVE_VERSION@@/${MKLIVE_VERSION}/" installer.sh > "$installer"
    install -Dm755 "$installer" "$INCLUDEDIR"/usr/bin/void-installer
    rm "$installer"
else
    echo installer.sh not found >&2
    exit 1
fi

if [ -n "$TRIPLET" ]; then
    VARIANT="${TRIPLET##*-}"
    REST="${TRIPLET%-*}"
    DATE="${REST##*-}"
    ARCH="${REST%-*}"
    build_variant "$VARIANT" "$@"
else
    for image in $IMAGES; do
        build_variant "$image" "$@"
    done
fi
