#!/bin/bash
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
UL="\033[4m"    # underline
INV="\033[7m"   # inverse background and foreground
FBLK="\033[30m" # foreground black
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FYEL="\033[33m" # foreground yellow

echo -e "$FYEL =========================================="
echo -e "$FRED 1) Script Sudo Olarak Calistirdin mi ?"
echo -e "$FYEL =========================================="
echo -e "$FRED 2) Makinanin Ismini Degistirdin mi ?"
echo -e "$FYEL =========================================="
echo -e "$FRED 3) Repo IP Adresini Degistirdin mi ?"
echo -e "$FYEL =========================================="
echo -e "$FRED 4) NTP IP Adresini Degistirdin mi ?"
echo -e "$FYEL =========================================="
echo -e "$FRED 5) FSTAP SHARE IP Adresini Degistirdin mi ?"
echo -e "$FYEL =========================================="
echo -e "$FRED 6) Ortam Degiskenlerini Ortak Kuruluma Gore Ayarladin mi ?"
echo -e "$FGRN =========================================="
read -r -p "Devam Etmek Istiyor musunuz? [Y/n] " input
tput init
case $input in
    [yY][eE][sS]|[yY])
 echo "Yes"

 #ex -s -c '3i|hello world' -c x file.txt
 #ex -s -c '/hello/i|world' -c x file.txt

SCRIPTPATH="$( cd "$(dirname " $0")" ; pwd -P )"

DIR_FOR_USERLIST_FILES=$SCRIPTPATH/ORTAK-KURULUM/userlist

DIR_FOR_ORTAM_DEGISKEN_FILES=$SCRIPTPATH/ORTAK-KURULUM/bashrc

DIR_FOR_SYSCTL_LIMIT_FILES=$SCRIPTPATH/ORTAK-KURULUM/sysctl_limit

CMAKE_PATH=$SCRIPTPATH/ORTAK-KURULUM/artifactory/64/cmake

VCODE_PATH=$SCRIPTPATH/ORTAK-KURULUM/vcode

NET_INTERFACE_PATH=$SCRIPTPATH/ORTAK-KURULUM/NetworkCards

BACKGROUND_IMG_PATH=$SCRIPTPATH/ORTAK-KURULUM/logo

REPO_ADRESS=$SCRIPTPATH/ORTAK-KURULUM/local-repo

VCODE_ADRESS=$SCRIPTPATH/ORTAK-KURULUM/vcode

STARTUP_PATH=$SCRIPTPATH/ORTAK-KURULUM/startup

SET_HOSTNAME=AVI-FFS3-A320
# Makina-ISMI_BURAYA_GIR

hostnamectl set-hostname $SET_HOSTNAME
hostnamectl

# SET LOCAL REPO and Disable Kernel Update (Aviyonik Sunucuyu Kernel Update Bozuyor)
ex -s -c '5i|exclude=kernel*' -c x /etc/yum.conf 
mkdir -p /root/repo
mv /etc/yum.repos.d/* /root/repo
cp -r $REPO_ADRESS/CentOS-Local.repo /etc/yum.repos.d/

# DISABLE SE LINUX ON CENTIS 7.6 and Stop Firewall

sed -i 's/enforcing/disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
systemctl mask --now firewalld

# Change Background Image
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/
#html/desktop_migration_and_administration_guide/customize-desktop-backgrounds

cp -r $BACKGROUND_IMG_PATH/Havelsan_Logo.jpg /home/hvladmin/Pictures
mkdir -p  /usr/local/share/backgrounds
cp -r $BACKGROUND_IMG_PATH/Havelsan_Logo.jpg /usr/local/share/backgrounds/wallpaper.jpg
cp -r $BACKGROUND_IMG_PATH/00-background /etc/dconf/db/local.d/
cp -r $BACKGROUND_IMG_PATH/background /etc/dconf/db/local.d/locks/
cp -r $BACKGROUND_IMG_PATH/00-default-wallpaper /etc/dconf/db/gdm.d/locks/
dconf update

# Change ScreenSaver Image
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/
#html/desktop_migration_and_administration_guide/customize-desktop-backgrounds
cp -r $BACKGROUND_IMG_PATH/01-screensaver /etc/dconf/db/gdm.d/
dconf update

# Change Lock Screen Image
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/
#html/desktop_migration_and_administration_guide/customizing-login-screen
cp -r $BACKGROUND_IMG_PATH/01-logo /etc/dconf/db/gdm.d/
dconf update

# Change Login Screen Image
cp -r $BACKGROUND_IMG_PATH/Havelsan_Logo.jpg /usr/share/backgrounds/day.jpg
cp -r $BACKGROUND_IMG_PATH/Havelsan_Logo.jpg /usr/share/backgrounds/default.jpg

# NETWORK DUZELTMELERI
cd $NET_INTERFACE_PATH

# Add Routing SIM Interface and Create 
echo -e "$FYEL ====================================================================="
echo -e "$FRED Route Girilecek SIM NET Interface Adini Girin ? Ornek eno1,eno2,eno3"
echo -e "$FYEL ====================================================================="
tput init
read WHITESPACE_InterfaceName
InterfaceName="$(echo -e "${WHITESPACE_InterfaceName}" | tr -d '[:space:]')"
echo $InterfaceName > $NET_INTERFACE_PATH/InterfaceNames.txt

for interface in $( cat InterfaceNames.txt ); do
    touch $NET_INTERFACE_PATH/route-$interface
    cat $NET_INTERFACE_PATH/General.txt >> $NET_INTERFACE_PATH/route-$interface
    ip_adress="$(ip addr show $interface |grep global |awk '{print $2}' |awk '{gsub("/24", "");print}')"
    echo $ip_adress
    sed -i s/1.1.1.1/$ip_adress/g route-$interface
    cp -r  route-$interface /etc/sysconfig/network-scripts/
    rm -rf $NET_INTERFACE_PATH/sed*
    rm -rf $NET_INTERFACE_PATH/route-*
    rm -rf $NET_INTERFACE_PATH/InterfaceNames.txt
done

# Restart Network Service

systemctl restart network

# INSTALL PACKAGE

yum -y install sshpass
yum -y install wireshark
yum -y install wireshark-gnome
yum -y install php
yum -y install mesa-libGL-devel.x86_64
yum -y install unixODBC
yum -y install unixODBC-devel
yum -y install libXScrnSaver-1.2.2-6.1.el7.x86_64
# OTHERS
yum -y install meld
yum -y install libreoffice
yum -y install ntfs-3g
yum -y install libXScrnSaver
yum -y install ntp
yum -y install samba-client
yum -y install samba-common
yum -y install cifs-utils
yum -y install x11vnc
yum -y install nmap
yum -y install nc
yum -y install tcpdump

# Change NetworkManager Service Status

systemctl disable NetworkManager
systemctl stop NetworkManager

# Change NTP Server IP

#sed -i 's/"server 0.centos.pool.ntp.org iburst"/"#server 0.centos.pool.ntp.org iburst"/g'
#sed -i 's/"server 1.centos.pool.ntp.org iburst"/"#server 1.centos.pool.ntp.org iburst"/g'
#sed -i 's/"server 2.centos.pool.ntp.org iburst"/"#server 2.centos.pool.ntp.org iburst"/g'
#sed -i 's/"server 3.centos.pool.ntp.org iburst"/"#server 3.centos.pool.ntp.org iburst"/g'
#ex -s -c '25i' -c x $DIR_FOR_SYSCTL_LIMIT_FILES/ntp.txt
cp -r $DIR_FOR_SYSCTL_LIMIT_FILES/ntp.txt /etc/ntp.conf
systemctl start ntpd
systemctl enable ntpd

# Change X11VNC

ex -s -c '88i|x11vnc -noxdamage -display :0 -forever -shared -nopw &' -c x /etc/gdm/Init/Default

ex -s -c '4i|KillInitClients=false' -c x /etc/gdm/custom.conf

# Add SHARE FOLDER on FSTAB and clear blank line
mkdir /home/SHARE
touch /etc/credentials.txt
chmod 600 /etc/credentials.txt
ex -sc '1pu_|x' /etc/credentials.txt
ex -s -c '1i|username=sim' -c x /etc/credentials.txt
ex -s -c '2i|password=sim' -c x /etc/credentials.txt
sed -i '/^[[:space:]]*$/d' /etc/credentials.txt
echo '//192.168.31.35/SHARE /home/SHARE cifs credentials=/etc/credentials.txt,rw,guest,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nosetuids,x-systemd.automount 0 0' >> /etc/fstab

# INSTALL Visual Studio Code VCODE

cd $VCODE_PATH
rpm -ivh code-1.40.2-1574694258.el7.x86_64.rpm


# Create User and set Password

cd $DIR_FOR_USERLIST_FILES
 
for user in $( cat userlist.txt ); do
    useradd -m $user
    echo "user $user added successfully!"
    echo $user:$user | chpasswd
    echo "Password for user $user changed successfully"
done


# Add User Environment Variables and Depencies Library

cd $DIR_FOR_ORTAM_DEGISKEN_FILES

for ortam in $( cat degisken_user.txt); do
    sshpass -p$ortam scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ortam-degisken.txt $ortam@localhost:/home/$ortam/
    echo $ortam | sudo -S su - $ortam -c "cd /home/$ortam; cat ortam-degisken.txt >> .bashrc"
    echo $ortam | sudo -S su - $ortam -c "cd ~; source .bashrc"
    echo $ortam | sudo -S su - $ortam -c "rm -rf ortam-degisken.txt"
    #Create Desktop, Downloads Pictures Folders
    echo $ortam | sudo -S su - $ortam -c "xdg-user-dirs-update"
    # Copy Havelsan_Logo.jpg User to Pictures
    cp -r $BACKGROUND_IMG_PATH/Havelsan_Logo.jpg /home/$ortam/Pictures
    chown $ortam:$ortam /home/$ortam/Pictures/Havelsan_Logo.jpg
    #Create Folder (Application, cots, data)
    echo $ortam | sudo -S su - $ortam -c "mkdir -p /home/$ortam/application/release/current_release"
    echo $ortam | sudo -S su - $ortam -c "mkdir -p /home/$ortam/application/cots"
    echo $ortam | sudo -S su - $ortam -c "mkdir -p /home/$ortam/application/data"
    echo $ortam | sudo -S su - $ortam -c "mkdir -p /home/$ortam/application/script"
    echo $ortam | sudo -S su - $ortam -c "mkdir -p /home/$ortam/Desktop/vcode"
    #Artifactory Cmake copy to /application/cots
    sshpass -p$ortam scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $CMAKE_PATH/cmake-3.9.3-Linux-x86_64.sh $ortam@localhost:/home/$ortam/application/cots
    sshpass -p$ortam scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $VCODE_ADRESS/*.vsix $ortam@localhost:/home/$ortam/Desktop/vcode
    #VSCODE Extension Run
    echo $ortam | sudo -S su - $ortam -c "cd $VCODE_ADRESS/VS_Code"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/austin.code-gnu-global-0.2.2.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/christian-kohler.path-intellisense-1.4.2.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/cpptools-linux.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/Gruntfuggly.todo-tree-0.0.160.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/ms-python.python-2019.10.41019.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/twxs.cmake-0.0.17.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/vector-of-bool.cmake-tools-1.1.3.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/webfreak.debug-0.23.1.vsix"
    echo $ortam | sudo -S su - $ortam -c "code --install-extension /home/$ortam/Desktop/vcode/zhuangtongfa.Material-theme-2.28.2.vsix"
#    echo $ortam | sudo -S su - $ortam -c "rm -rf /home/$ortam/Desktop/vcode"
    #Set Permission Data Folder
    cd /home/$ortam/application/cots
    sh cmake-3.9.3-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir
    cd $DIR_FOR_ORTAM_DEGISKEN_FILES
    chown nobody:nobody /home/$ortam/application/data
    chmod 2775 /home/$ortam/application/data
done


 # SYSCTL.conf and LIMITS.conf

cd $DIR_FOR_SYSCTL_LIMIT_FILES

sed -i '/maxlogins/r limits.txt' /etc/security/limits.conf
sed -i '/sysctl.conf(5)/r sysctl.txt' /etc/sysctl.conf
sysctl -p

# Change VISUDO add user permisson

sed -i '/NOPASSWD:/r sudoers.txt' /etc/sudoers


# Startup Variable Create Service

# Startup -> Creae main Folder

mkdir /root/variable
mkdir /root/variable/dev
mkdir /root/variable/sim
mkdir /root/variable/test

touch /var/log/variable.log

# Startup -> Copy Service Deamon -> Starting .Sh File

cp -r $STARTUP_PATH/variable.sh /root/variable/
chmod +x /root/variable/variable.sh


cp -r $STARTUP_PATH/variable.service /etc/systemd/system/

# Startup -> COPY .BASHRC root location

cp -r /home/dev/.bashrc /root/variable/dev/
cp -r /home/sim/.bashrc /root/variable/sim/
cp -r /home/test/.bashrc /root/variable/test/

# Startup -> COPY Under DEV, SIM, TEST User Folders and Restart Service

systemctl daemon-reload

systemctl enable variable.service

systemctl start variable.service

systemctl restart variable.service
 
# For Routing restart to network interface
systemctl restart network.service
# systemctl reboot

;;
    [nN][oO]|[nN])
echo "No"
       ;;
    *)
 echo "Invalid input..."
 exit 1
 ;;
esac
