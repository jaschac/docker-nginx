FROM debian:jessie
MAINTAINER Jascha Casadio "jascha@lostinmalloc.com"
RUN echo "deb http://nginx.org/packages/debian/ jessie nginx\ndeb-src http://nginx.org/packages/debian/ jessie nginx" > /etc/apt/sources.list.d/nginx.list
RUN apt-get update -qq
RUN apt-get install -y -qq wget
RUN wget -q -O - http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt-get install -y -qq nginx-full
ADD files/etc/nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-available/default
ADD scripts/setup.sh /usr/local/sbin/setup.sh
EXPOSE 80
EXPOSE 443
CMD setup.sh
CMD ["/usr/local/sbin/setup.sh"]
