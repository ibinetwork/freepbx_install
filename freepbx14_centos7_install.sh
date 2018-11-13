#!/bin/bash
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
setenforce 0
echo "Atualizando o Sistema Operacional"
sleep 5
yum -y update
echo "Instalando Ferramentas Úteis..."
sleep 5
yum -y install wget mtr vim mlocate nmap tcpdump mc nano lynx rsync screen htop subversion deltarpm net-tools minicom
echo "Iniciando a Instalação do FreePBX"
sleep 5
yum -y groupinstall core base "Development Tools"
adduser asterisk -m -c "Asterisk User"
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
yum -y install lynx tftp-server unixODBC mysql-connector-odbc mariadb-server mariadb httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel subversion kernel-devel git crontabs cronie cronie-anacron wget vim uuid-devel sqlite-devel net-tools gnutls-devel python-devel texinfo libuuid-devel expect
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum remove -y php*
yum install -y php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process php56w-xml php56w-opcache php56w-ldap php56w-intl php56w-soap
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum install -y nodejs
systemctl enable mariadb.service
systemctl start mariadb
cd /root
echo '#!/usr/bin/expect
set timeout 60
spawn mysql_secure_installation
expect {
"Enter current password for root (enter for none):" { send "\r"; exp_continue}
"Set root password?" { send "n\r"; exp_continue}
"Remove anonymous users?" { send "Y\r"; exp_continue}
"Disallow root login remotely?" { send "Y\r"; exp_continue}
"Remove test database and access to it?" { send "Y\r"; exp_continue}
"Reload privilege tables now?" { send "Y\r"; exp_continue}
}' > mysql_secure_installation.exp 
chmod +x mysql_secure_installation.exp
./mysql_secure_installation.exp
rm -fr mysql_secure_installation.exp
systemctl enable httpd.service
systemctl start httpd.service
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
wget -O jansson.tar.gz https://github.com/akheron/jansson/archive/v2.10.tar.gz
cd /usr/src
tar xvfz dahdi-linux-complete-current.tar.gz
tar xvfz libpri-current.tar.gz
rm -f dahdi-linux-complete-current.tar.gz libpri-current.tar.gz
cd dahdi-linux-complete-*
make all
make install
make config
cd /usr/src/libpri-*
make
make install
cd /usr/src
tar vxfz jansson.tar.gz
rm -f jansson.tar.gz
cd jansson-*
autoreconf -i
./configure --libdir=/usr/lib64
make
make install
cd /usr/src
tar xvfz asterisk-13-current.tar.gz
rm -f asterisk-13-current.tar.gz
cd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 --with-pjproject-bundled
contrib/scripts/get_mp3_source.sh
menuselect/menuselect --enable format_mp3 menuselect.makeopts
make
make install
make config
ldconfig
if [ ! -f /usr/src/asterisk-*/addons/format_mp3.so ];then
	cd asterisk-*
	menuselect/menuselect --enable format_mp3 menuselect.makeopts
	make
	make install
	make config
	ldconfig
fi
chkconfig asterisk off
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
chown -R asterisk. /var/www/
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service
cd /usr/src
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz
tar xfz freepbx-14.0-latest.tgz
rm -f freepbx-14.0-latest.tgz
cd freepbx
./start_asterisk start
./install -n
echo -e "\033[40;31m======================================================================================================================================== \033[1m"
echo -e "\033[40;31mSeu FreePBX está instalado. Acesse usando seu navegador e IP do servidor para continuar suas configurações! \033[1m"
echo -e "\033[40;31m======================================================================================================================================== \033[0m"
