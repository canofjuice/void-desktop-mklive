>[!WARNING]
>Work in progress...<br>
>Use at your own risk!

# Void Desktop Build Scripts

![Cinnamon Desktop](media/cinnamon.png)

![XFCE Desktop](media/xfce.png)

![KDE Desktop](media/kde.png)

This is a modified version of the Void Linux build scripts to include a pre-installed and pre-configured Desktop Environment out of the box.

Non-Free repositories are enabled by default, giving you the ability to install NVIDIA drivers and Steam after installation.

For Flatpaks, see https://flathub.org/setup/Void%20Linux, highly recommend to install Warehouse after installing Flatpaks for a simple GUI to install Flatpaks.

Background wallpapers included and are all from [Unsplash.](https://unsplash.com/)

## How complete is it?

The ISOs created contain a basic system with a Desktop Environment and a couple of pre-installed software, including a Firewall (UFW).

NVIDIA drivers are not pre-installed but are available to install out of the box.

You may need to install extra packages in order to get certain stuff working properly.

## How to use

Make sure you're using Void Linux. DistroBox recommended if you're on a different distro.

Git clone the repository, run `setup-repo.sh` ***ONLY ONCE!***

Open a terminal and run:

`./build-cinnamon.sh` to create a ISO of the Cinnamon variant,

`./build-xfce.sh` to create a ISO of the XFCE variant,

`./build-kde.sh` to create a ISO of the KDE variant or

`./build-all.sh` to create ISO of each variant.
