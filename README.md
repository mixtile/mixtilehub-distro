# mixtilehub-distro
Build images using yocto for Mixtile Hub.


## How to build the image
Clone the external submodules :

`git submodule update --init`

Source the file `init-build-env`:

`. init-build-env`

And build the image:

`bitbake mixtilehub-minimal` 


## How to boot

### Boot from sdcard

To create a sdcard with root partition, use this script:

`sudo ./create-boot-sdcard.sh -d /dev/??? -i <image>`

Replace ??? with the port of your sdcard. The `<image>` is mixtilehub-minimal.

After the sdcard is created, insert the sdcard into the sdcard slot of the board and powerup the board.

### Boot from eMMC
TBD


## How to login
The ethernet network interface is configured as a dhcp client. A sshd is running. Use root for login, no password.

Also you can login via serial, and the serial setting is `115200n8` .

## Known Issues
1. WIFI/BT doesn't work.
2. GPU doesn't work.

