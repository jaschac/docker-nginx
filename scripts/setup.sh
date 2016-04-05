#!/bin/bash
#
# This scripts sets the container up the container with the desiered service(s) properly running.
#

set -e

: ${NGINX_PID:="/run/nginx.pid"}
: ${NGINX_USERNAME:="www-data"}
: ${NGINX_WORKER_CONNECTIONS:="128"}
: ${NGINX_WORKER_PROCESSES:="2"}

# Check if the user exists
if ! id -u $NGINX_USERNAME >/dev/null 2>&1; then
	echo "User $NGINX_USERNAME does not exist." >> /dev/stderr
	exit 1
fi

# Inject user-defined data into /etc/nginx/nginx.conf
if [ -f /etc/nginx/nginx.conf ]
then
	sed -i 's@<NGINX_PID>@'${NGINX_PID}@g /etc/nginx/nginx.conf
	sed -i 's@<NGINX_PID>@'${NGINX_PID}@g /etc/nginx/nginx.conf
	sed -i 's@<NGINX_USERNAME>@'${NGINX_USERNAME}@g /etc/nginx/nginx.conf 
	sed -i 's@<NGINX_WORKER_CONNECTIONS>@'${NGINX_WORKER_CONNECTIONS}@g /etc/nginx/nginx.conf
	sed -i 's@<NGINX_WORKER_PROCESSES>@'${NGINX_WORKER_PROCESSES}@g /etc/nginx/nginx.conf
else
	echo "Cannot find /etc/nginx/nginx.conf" >> /dev/stderr
	exit 1
fi

# Check if /var/www exists.
if [ -d /var/www ]
then
	# Nginx owns it
	chown -R $NGINX_USERNAME:$NGINX_USERNAME /var/www
else
	# Die
	echo "/var/www does not exist." >> /dev/stderr
	exit 1
fi

# Check if the Nginx configuration is correct
/usr/sbin/nginx -c /etc/nginx/nginx.conf -t >/dev/null 2>&1
if [ $? -eq 1 ]
then
	echo "The Nginx's configuration is not correct." >> /dev/stderr
	exit 1
fi

# Start Nginx
/usr/sbin/nginx -c /etc/nginx/nginx.conf
