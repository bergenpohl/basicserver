# Debian v11
FROM debian:bullseye

MAINTAINER bpohl

COPY srcs /root/srcs/

WORKDIR /root/srcs/

RUN apt-get update

RUN apt-get -y install	\
	sudo		\
	vim man		\
	git curl wget	\
	passwd openssl	\
	adduser		\
	unzip		\
	openssh-server	\
	openssh-client	\
	ufw vsftpd	\
	nginx		\
	nodejs		\
	mariadb-server	\
	mariadb-client	\
	php php-fpm php-mbstring php-xml php-zip	\
	php-mysql php-curl php-imagick php-gd php-intl
	
RUN apt-get -y upgrade
RUN apt-get -y remove apache2
RUN apt-get -y autoremove

# Run config on startup
ENTRYPOINT ["bash", "/root/srcs/scripts/startup.sh"]
