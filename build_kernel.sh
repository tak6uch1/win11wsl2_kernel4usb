#!/bin/bash

#TAGVERNUM=`uname -r -v | sed 's/\-.*//'`
TAGVERNUM=5.15.57.1
TAGVER=linux-msft-wsl-${TAGVERNUM}
echo "TAGVERNUM:$TAGVERNUM"
echo "TAGVER:$TAGVER"

USER=`whoami`
nproc=5

rundir=$PWD

# Update and install needed tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential flex bison \
    libgtk2.0-dev libelf-dev libncurses-dev autoconf \
    libudev-dev libtool zip unzip v4l-utils libssl-dev \
    python3-pip cmake git iputils-ping net-tools

# Download source code of WLS2 kernel
cd /usr/src
#sudo git clone -b ${TAGVER} https://github.com/microsoft/WSL2-Linux-Kernel.git ${TAGVERNUM}-microsoft-standard
#cd ${TAGVERNUM}-microsoft-standard
sudo git clone https://github.com/microsoft/WSL2-Linux-Kernel.git -b ${TAGVER} --depth 1
cd WSL2-Linux-Kernel

# Copy config file
sudo cp $rundir/config .config
sudo chmod 777 .config
# If you want to change config setting, execute below.
#sudo make menuconfig

# Build kernel
sudo make clean
#sudo make -j $nproc KCONFIG_CONFIG=.config && sudo make modules_install -j $nproc $$ sudo make install -j $nproc
sudo make -j$(nproc) && sudo make modules_install -j$(nproc) && sudo make install -j$(nproc)

# Build USBIP
cd tools/usb/usbip
sudo ./autogen.sh
sudo ./configure
sudo sed 's/-Werror//g' -i Makefile
sudo sed 's/-Werror//g' -i src/Makefile
sudo sed 's/-Werror//g' -i libsrc/Makefile
sudo make install -j $nproc

# Copy library into the place which USBIP can find it at
sudo cp libsrc/.libs/libusbip.so.0 /lib/libusbip.so.0

# Copy kernel into user's home directory
#sudo cp /usr/src/${TAGVERNUM}-microsoft-standard/vmlinux.o /mnt/c/Users/$USER/vmlinux
sudo cp /usr/src/WSL2-Linux-Kernel/vmlinux /mnt/c/Users/$USER/vmlinux

# Make .wslconfig
cat << EOF > /mnt/c/Users/$USER/.wslconfig
[WSL2]
kernel=C:\\\\Users\\\\$USER\\\\vmlinux
EOF

# Get VirtualHere
cd $rundir
sudo apt-get install -y libgtk2.0-0
wget https://www.virtualhere.com/sites/default/files/usbclient/vhuit64 && \
sudo chmod 777 vhuit64

