FROM ubuntu:12.04
MAINTAINER Docker <tony.arianto@klola.id>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m apps && echo "apps:s1q2w3e4r5t" | chpasswd
RUN adduser apps sudo
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install sudo apache2 nano proftpd curl imagemagick apache2 libapache2-mod-php5 php5-mysql php5-mcrypt php5-curl php5-imagick php5-ldap
RUN apt-get -y --force-yes --fix-missing install \
    python-pip && \
    apt-get clean

RUN mkdir -p /home/apps/logs /home/apps/public_html /home/apps/shares
RUN sed -i "s|# DefaultRoot|DefaultRoot |g" /etc/proftpd/proftpd.conf
RUN pip install supervisor==3.2.3
COPY supervisord.conf /usr/local/etc/supervisord.conf

ADD si_lib.so /usr/lib/php5/20090626
ADD si_lib.ini /etc/php5/conf.d/
RUN mv /etc/php5/apache2/php.ini /etc/php5/apache2/php_old.ini
ADD php.ini /etc/php5/apache2/
RUN mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default_old
ADD default /etc/apache2/sites-available/
RUN chown -R apps:apps /home/apps
RUN echo "Asia/Jakarta" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
EXPOSE 21 20 80
CMD ["supervisord"]
