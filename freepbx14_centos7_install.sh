#!/bin/bash
clear
# Script de Instalação customizada do FreePBX 14 e Asterisk 13 no CentOS7
# Autor: Rafael Tavares 
# Contribuinte: Janduy Euclides
echo "                                                           "
echo "======================================================================================="
echo "# Script de Instalação customizada do FreePBX 14 e Asterisk 13 no CentOS7"
echo "# Autor: Rafael Tavares"
echo "# Contribuinte: Janduy Euclides"
echo "# Versão 1.0 - 12/11/2018 : Instalação dos pré requisitos do sistema linux,"
echo "  download dos pacotes para instalação do FreePBX e Asterisk."
echo "# Versão 1.1 - 18/02/2019 : Alterado a versão do pacote dahdi para versão 2.10"
echo "  instalação do telnet e do SNGREP."
echo "# Versão 1.2 - 18/02/2019 : Adicionado audio pt-br,"
echo "  codec g729 e tratamento hangup cause."
echo "# Versão 1.3 - 25/02/2019 : Download e Instalação dos principais modulos:"
echo "  > timeconditions;													   "
echo "  > bulkhandler;														   "
echo "  > customcontexts;													   "
echo "  > ringgroups;														   "
echo "  > queues;															   "
echo "  > ivr; 																   "
echo "  > asteriskinfo;														   "
echo "  > iaxsettings.														   "
echo "======================================================================================="
echo "# Versão 1.3.1 - 11/07/2019 : Download e Instalação de modulos adicionais:"
sleep 10
yum install epel-release -y
yum install cowsay -y
clear
echo ""
cowsay "DESABILITANDO SELINUX"
echo ""
sleep 5
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
setenforce 0
clear
echo ""
cowsay "DESABILITANDO IPV6"
echo ""
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo ""
cowsay "ATUALIZANDO O SISTEMA OPERACIONAL"
echo ""
sleep 5
yum -y update
clear
echo ""
cowsay "INSTALANDO FERRAMENTAS UTEIS..."
echo ""
sleep 5
yum install -y wget mtr vim mlocate nmap telnet tcpdump mc nano lynx rsync screen htop subversion deltarpm net-tools ntsysv minicom
clear
yum clean all
yum makecache
yum update -y
clear
# Instalação do SNGREP
echo ""
cowsay "INSTALANDO SNGREP"
echo ""
sleep 5
echo '[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/
' > /etc/yum.repos.d/irontec.repo
rpm --import http://packages.irontec.com/public.key
yum install sngrep -y
clear
echo ""
cowsay "INICIANDO A INSTALAÇÃO DO FREEPBX"
echo ""
sleep 5
yum install -y kernel-devel.`uname -m` epel-release
yum -y groupinstall core base "Development Tools"
adduser asterisk -m -c "Asterisk User"
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
yum install -y lynx tftp-server unixODBC mysql-connector-odbc mariadb-server mariadb httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel subversion kernel-devel git crontabs cronie cronie-anacron wget vim uuid-devel sqlite-devel net-tools gnutls-devel python-devel texinfo libuuid-devel expect
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
clear
echo ""
cowsay "INSTALANDO DAHDI"
echo ""
sleep 5
cd /usr/src
wget https://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-2.10.0+2.10.0.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
wget -O jansson.tar.gz https://github.com/akheron/jansson/archive/v2.10.tar.gz
cd /usr/src
tar xvfz dahdi-linux-complete-2.10.0+2.10.0.tar.gz
tar xvfz libpri-current.tar.gz
rm -f dahdi-linux-complete-2.10.0+2.10.0.tar.gz libpri-current.tar.gz
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
clear
echo ""
cowsay "INSTALANDO ASTERISK 13"
echo ""
sleep 5
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
sed -i s/128M/384M/g /etc/php.ini
sed -i s/20M/120M/g /etc/php.ini
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > /etc/firewalld/services/asterisk.xml
echo "<service>" >> /etc/firewalld/services/asterisk.xml
echo "  <short>asterisk</short>" >> /etc/firewalld/services/asterisk.xml
echo "  <description>Asterisk is a software implementation of a telephone private branch exchange (PBX).</description>" >> /etc/firewalld/services/asterisk.xml
echo "  <port protocol=\"udp\" port=\"10000-20000\"/>" >> /etc/firewalld/services/asterisk.xml
echo "  <port protocol=\"udp\" port=\"4569\"/>" >> /etc/firewalld/services/asterisk.xml
echo "  <port protocol=\"udp\" port=\"2727\"/>" >> /etc/firewalld/services/asterisk.xml
echo "  <port protocol=\"udp\" port=\"5060-5061\"/>" >> /etc/firewalld/services/asterisk.xml
echo "</service>" >> /etc/firewalld/services/asterisk.xml
clear
echo ""
cowsay "INSTALANDO O FREEPBX"
echo ""
sleep 5
cd /usr/src
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz
tar xfz freepbx-14.0-latest.tgz
rm -f freepbx-14.0-latest.tgz
cd freepbx
./start_asterisk start
./install -n
clear
echo ""
cowsay "ADIONANDO FREEPBX A INICIALIZAÇÃO"
echo ""
sleep 5
echo "[Unit]" > /etc/systemd/system/freepbx.service
echo "Description=Servidor de VoIP - FreePBX" >> /etc/systemd/system/freepbx.service
echo "After=mariadb.service" >> /etc/systemd/system/freepbx.service
echo "" >> /etc/systemd/system/freepbx.service
echo "[Service]" >> /etc/systemd/system/freepbx.service
echo "Type=oneshot" >> /etc/systemd/system/freepbx.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/freepbx.service
echo "ExecStart=/usr/sbin/fwconsole start -q" >> /etc/systemd/system/freepbx.service
echo "ExecStop=/usr/sbin/fwconsole stop -q" >> /etc/systemd/system/freepbx.service
echo "" >> /etc/systemd/system/freepbx.service
echo "[Install]" >> /etc/systemd/system/freepbx.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/freepbx.service
systemctl enable freepbx.service
firewall-cmd --add-service=asterisk --permanent
firewall-cmd --reload
clear
svn co https://github.com/ibinetwork/IssabelBR/trunk/ /usr/src/IssabelBR
clear
echo ""
cowsay "INSTALANDO AUDIO EM PORTUGUÊS BRASIL"
echo ""
sleep 5
rsync --progress -r -u /usr/src/IssabelBR/audio/ /var/lib/asterisk/sounds/
sed -i '/language=pt_BR/d' /etc/asterisk/sip_general_custom.conf
echo "language=pt_BR" >> /etc/asterisk/sip_general_custom.conf
sed -i '/language=pt_BR/d' /etc/asterisk/iax_general_custom.conf
echo "language=pt_BR" >> /etc/asterisk/iax_general_custom.conf
sed -i '/defaultlanguage=pt_BR/d' /etc/asterisk/asterisk.conf
echo "defaultlanguage=pt_BR" >> /etc/asterisk/asterisk.conf
clear
echo ""
cowsay "INSTALANDO CODEC G729"
echo ""
sleep 5
 cp /usr/src/IssabelBR/codecs/codec_g729-ast130-gcc4-glibc2.2-x86_64-pentium4.so /usr/lib64/asterisk/modules/codec_g729.so
 chmod 755 /usr/lib64/asterisk/modules/codec_g729.so
 asterisk -rx "module load codec_g729"
 clear
echo ""
cowsay "INSTALANDO TRATAMENTO HANGUPCAUSE"
echo ""
sleep 5
sed -i '/extensions_tratamento_hangupcause.conf/d' /etc/asterisk/extensions_override_freepbx.conf
echo "#include /etc/asterisk/extensions_tratamento_hangupcause.conf" >> /etc/asterisk/extensions_override_freepbx.conf
rsync --progress -r /usr/src/IssabelBR/etc/asterisk/ /etc/asterisk/
chown asterisk.asterisk /etc/asterisk/extensions_tratamento_hangupcause.conf
echo ""
rm -Rf /usr/src/IssabelBR
clear
echo ""
cowsay "DOWNLOAD E INSTALAÇÃO DOS PRINCIPAIS MODULOS"
echo ""
sleep 5
fwconsole ma downloadinstall cel calendar timeconditions bulkhandler customcontexts ringgroups queues ivr asteriskinfo iaxsettings backup callforward announcement callrecording daynight endpointman extensionsettings featurecodeadmin recordings sipsettings soundlang voicemail donotdisturb
fwconsole r a
mkdir /tftpboot
chmod -Rf 777 /tftpboot
echo ""
updatedb
clear
echo -e "\033[40;31m======================================================================================================================================== \033[1m"
echo -e "\033[40;31mSeu FreePBX está instalado. Acesse usando seu navegador e IP do servidor para continuar suas configurações! \033[1m"
echo -e "\033[40;31m======================================================================================================================================== \033[1m"
echo -e "\033[40;31mSEU SISTEMA IRA REINICIAR EM 15s (PRESSIONE CTRL+C PARA RENICIAR MANUALMENTE) \033[1m"
echo -e "\033[40;31m======================================================================================================================================== \033[0m"
sleep 15
reboot
