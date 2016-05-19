#!/bin/bash
cd $(dirname $0)
WORKPATH=$(pwd)
DATAPATH=/data
cd $WORKPATH

LANG=C

yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel  libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers  libssh2.x86_64 libssh2-devel.x86_64 libssh2-docs.x86_64 rsync cmake readline-devel gnutls gnutls-devel bc unzip pigz pbzip2 iftop screen tmux sysstat procps iftop wget libpcap vim parted pigz libevent libevent-devel ImageMagick ImageMagick-devel libmemcached libmemcached-devel  cyrus-sasl-devel sphinx libsphinxclient libsphinxclient-devel pcre-devel

# 编译安装PHP所需的支持库
tar zxvf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1/
./configure --prefix=/usr/local
make
make install
ln -s /usr/local/lib/libiconv.so.2.5.0 /usr/local/lib64/libiconv.so
cd ../

tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make
make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make
make install
cd ../../


tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make
make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config


tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
/sbin/ldconfig
./configure
make
make install
cd ../

echo "/usr/local/lib" >> /etc/ld.so.conf
echo "/usr/local/lib64" >> /etc/ld.so.conf
ldconfig


# 编译安装mysql
cd $WORKPATH
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql -d /home/mysql -s /sbin/nologin mysql

tar zxvf mysql-5.6.22.tar.gz
cd mysql-5.6.22
cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.6.22 -DWITH_EXTRA_CHARSETS=all -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=yes -DWITH_INNODB_MEMCACHED=1 -DENABLE_GPROF=1
if [ $? -ne 0 ] ; then
        echo "CMAKE MYSQL FAILED"
        exit 1
fi

make && make install
if [ $? -ne 0 ] ; then
        echo "MAKE MYSQL FAILED"
        exit 1
fi


ln -s /usr/local/mysql-5.6.22 /usr/local/mysql

chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
cd ../

cd /usr/local/mysql
ln -s lib lib64

echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig

export PATH=$PATH:/usr/local/mysql/bin


# 安装启动mysqld
cd $WORKPATH
MYSQLPORT=3306
mkdir -p ${DATAPATH}/mysql/${MYSQLPORT}/data/
mkdir -p ${DATAPATH}/mysql/${MYSQLPORT}/binlog/
mkdir -p ${DATAPATH}/mysql/${MYSQLPORT}/relaylog/
mkdir -p ${DATAPATH}/mysql/${MYSQLPORT}/log/
chown -R mysql:mysql  ${DATAPATH}/mysql/

/bin/cp -f my_5.6.6.cnf ${DATAPATH}/mysql/${MYSQLPORT}/
ln -s ${DATAPATH}/mysql/${MYSQLPORT}/my_5.6.6.cnf /etc/my.cnf

/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=${DATAPATH}/mysql/${MYSQLPORT}/data --user=mysql --defaults-file=${DATAPATH}/mysql/${MYSQLPORT}/my_5.6.6.cnf

/usr/local/mysql/bin/mysqld_safe --defaults-file=${DATAPATH}/mysql/${MYSQLPORT}/my_5.6.6.cnf 2>&1 > /dev/null &

if [ $? -ne 0 ] ; then
    echo "===============================MySQL Start Fail=============================="
    exit 1
fi

sleep 10

echo "/usr/local/mysql/bin/mysqld_safe --defaults-file=${DATAPATH}/mysql/${MYSQLPORT}/my_5.6.6.cnf --user=mysql 2>&1 > /dev/null &" >> /etc/rc.local

# 安装postgresql
cd $WORKPATH
tar jxvf postgresql-9.3.4.tar.bz2
cd postgresql-9.3.4
./configure --prefix=/usr/local/postgresql-9.3.4 --without-readline
make
make install
if [ $? -ne 0 ] ; then
    echo "PostgreSQL install fail"
    exit 1
fi
cd ../


ln -s /usr/local/postgresql-9.3.4 /usr/local/postgresql
ln -s /usr/local/postgresql/bin/pg_dump /usr/bin/pg_dump
ln -s /usr/local/postgresql/bin/psql /usr/bin/psql
echo "/usr/local/postgresql/lib" >> /etc/ld.so.conf
ldconfig
export PATH=$PATH:/usr/local/postgresql/bin


# 安装freetds
cd $WORKPATH
tar jxvf freetds-0.91.tar.bz2
cd freetds-0.91
./configure --prefix=/usr/local/freetds --with-tdsver=8.0 --enable-msdblib
make && make install
if [ $? -ne 0 ] ; then
    echo "freetds install fail"
    exit 1
fi
cp include/tds.h /usr/local/freetds/include
cp src/tds/.libs/libtds.a  /usr/local/freetds/lib
cd ../

echo "/usr/local/freetds/lib/" > /etc/ld.so.conf.d/freetds.conf
ldconfig
/bin/cp -f freetds_node.conf  /usr/local/freetds/etc/freetds.conf



# 编译安装PHP(FastCGI模式)
cd $WORKPATH 
tar jxvf php-5.2.13.tar.bz2
gzip -cd php-5.2.13-fpm-0.5.13.diff.gz | patch -d php-5.2.13 -p1
cd php-5.2.13
./configure  --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-mssql=/usr/local/freetds --with-pdo-dblib=/usr/local/freetds --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-ftp --without-pear --with-mime-magic=/usr/share/file/magic.mime

make ZEND_EXTRA_LIBS='-liconv'
if [ $? -ne 0 ] ; then
        echo "PHP install fail"
        exit 1
fi
make install
cd ../
export PATH=$PATH:/usr/local/php/bin
cp php.ini /usr/local/php/lib/php.ini
#如果不安装php-fpm,则需要创建目录 mkdir -pv /usr/local/php/etc
ln -s /usr/local/php/lib/php.ini /usr/local/php/etc/php.ini

#编译安装PHP5扩展模块
# pdo_dblib - ms sql server
#cd php-5.5.27/ext/pdo_dblib
#/usr/local/php/bin/phpize
#./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-dblib=/usr/local/freetds
#make && make install

cd $WORKPATH
# pdo_mysql
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/mysql/include
export CPP_INCLUDE_PATH=$CPP_INCLUDE_PATH:/usr/local/mysql/include
tar zxvf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make
make install
cd ../

# pgsql - postgresql
tar xvf PDO_PGSQL-1.0.2.tgz
cd PDO_PGSQL-1.0.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-pgsql=/usr/local/postgresql
make
make install
cd ../


# redis
tar xvf redis-2.2.5.tgz
cd redis-2.2.5
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../

# memcache
tar xvf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config 
make
make install
cd ../


# libevent
tar xvf libevent-0.1.0.tgz
cd libevent-0.1.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../

#imagick
tar zxvf imagick-2.1.1.tgz
cd imagick-2.1.1
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/
make && make install
cd ../

# sphinx
tar zxvf sphinx-1.1.0.tgz
cd sphinx-1.1.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# memcached
tar zxvf memcached-1.0.0.tgz
cd memcached-1.0.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../


tar zxvf igbinary-1.2.1.tgz
cd igbinary-1.2.1
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../


#创建www用户和组，以供www及blog两个虚拟主机使用的目录
/usr/sbin/groupadd www
#/usr/sbin/useradd -g www www
/usr/sbin/useradd -g www -d /home/www -s /sbin/nologin www

#创建php-fpm配置文件(php-fpm是为PHP打的一个FastCGI管理补丁，可以平滑变更php.ini配置而无需重启php-cgi
/bin/cp -f php-fpm.conf /usr/local/php/etc/php-fpm.conf

# 启动php-cgi进程，监听127.0.0.1的9000端口，进程数为64，用户为www
ulimit -SHn 65535
echo "kernel.shmmax = 68719476736" >> /etc/sysctl.conf
sysctl -p
mkdir -p /usr/local/php/log
/usr/local/php/sbin/php-fpm start
if [ $? -ne 0 ] ; then
        echo "===============================启动php-fpm出错=============================="
        exit 1
fi


echo '========以下是nginx安装，如果有需要手动调整执行===================='
exit

#nginx 安装
# 安装nginx所需的pcre库
cd $WORKPATH
tar zxvf pcre-8.10.tar.gz
cd pcre-8.10/
# mongodb需要./configure后面的两个参数(特别是最后一个)
./configure --enable-utf8  --enable-unicode-properties
make && make install
ldconfig
cd ../


tar zxvf nginx-1.9.15.tar.gz
cd nginx-1.9.15
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module 
make && make install
cd ../

echo  "===========memcached 需要修改编译参数再进行编译安装===================="
exit
# 安装memcached服务 去掉Makefile参数Werror
cd $WORKPATH
tar zxvf memcached-1.4.24.tar.gz
cd memcached-1.4.24
./configure --prefix=/usr/local/memcached
make && make install
if [ $? -ne 0 ] ; then
    echo "install memcached fail"
    exit 1
fi
/usr/local/memcached/bin/memcached -d -u root -m 200 -p 11211

echo "/usr/local/memcached/bin/memcached -d -u root -m 200 -p 11211" >> /etc/rc.local

# 安装redis服务
cd $WORKPATH
tar zxvf redis-2.8.9.tar.gz
cd redis-2.8.9
make && make install
if [ $? -ne 0 ] ; then
    echo "install memcached fail"
    exit 1
fi
cd $WORKPATH
mkdir -pv /usr/local/redis/{conf,data,logs}
/bin/cp -f redis.conf /usr/local/redis/conf
cd /usr/local/redis; bin/redis-server conf/redis.conf &
echo "cd /usr/local/redis; bin/redis-server conf/redis.conf" >> /etc/rc.local
