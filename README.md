# jaschac/nginx
#### Table of Contents
1. [Overview](#overview)
2. [Description](#description)
3. [Setup](#setup)
    * [Pulling from the Docker Hub](#pulling-from-the-docker-hub)
    * [Building the Image from the Source](#building-the-image-from-the-source)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Contact](#contact)

### Overview
The `jaschac/nginx` image deploys an Nginx container that serves any kind of web site, be it static or dynamic. 

### Description
The `jaschac/nginx` image provides users with a very flexible solution to serve any number and kind of web applications. It is build through the APT provider, which feeds at the official Nginx repository. As such:

 * It cannot serve anything that requires additional modules, such as Phusion Passenger, as they do require building Nginx from the source.
 * It is unware of the content being server and how to serve it. The client is expected to link `jaschac/nginx` with a container serving `php-fpm` if PHP is to be served. `jaschac/nginx` acts as a pure proxy.
 * It does expect the virtual host configuration files to serve to be provided through a volume.

Being unaware of the content being server, the `jaschac/nginx` image is **NOT responsible of**:

 * Installing and managing any WSGI/FastCGI process. The client must provide and link them.
 * Validating the virtual host configuration files provided. If they are not valid, the container will stop.

### Setup
There are two ways to get and use the `jaschac/nginx` image to create containers:

 1. Pulling it from the Docker Hub, which is the simplest option.
 2. Cloning the Git repository and building it from the source. This solution is the best in case you want to review or modify the code before the image is generated.

#### Pulling from the Docker Hub
The `jaschac/nginx` image can be easily pulled from the Docker Hub.

```bash
    $ sudo docker pull jaschac/nginx:latest
```
Once pulled, the image is ready to be used to create containers. See [usage](#usage) for detailed examples on how to run containers with `jaschac/nginx`.
```bash
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
jaschac/nginx             latest              3cd164eccf7b        About an hour ago   244.2 MB
```

#### Building the Image from the Source
The `jaschac/nginx`'s image is distributed under the Apache 2.0, which means it can be freely pulled from [Github](https://github.com/jaschac/docker-nginx), modified and used to build the image. Please, make sure you read the [License](https://github.com/jaschac/docker-nginx/blob/master/LICENSE).

```bash
$ git clone git@github.com:jaschac/docker-nginx.git nginx
```
 Once pulled, the image will have the following structure:
```bash
nginx/
├── [ 631]  Dockerfile
├── [4.0K]  files
│   └── [4.0K]  etc
│       └── [4.0K]  nginx
│           └── [ 646]  nginx.conf
├── [ 31K]  LICENSE
├── [ 411]  metadata.json
├── [  15]  README
├── [5.4K]  README.md
└── [4.0K]  scripts
    └── [   0]  setup.sh
```

The image can be then built with the following command(s):

```bash
    $ sudo docker build -t jaschac/nginx -f nginx/Dockerfile nginx/
    Successfully built 3cd164eccf7b
    $ sudo docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
jaschac/nginx             latest              3cd164eccf7b        About an hour ago   244.2 MB
```

## Usage
The `jaschac/nginx` does expect the following information to be provided by the client through volumes:

 * The virtual host configuration file of each location to serve. The file is expected to properly validate against the `nginx -t` command and must be mounted in the `/etc/nginx/sites-enabled/` directory.
 * The content to serve, **if** it's pure HTML and we don't want to serve it through another linked container.

In the following example, we serve a static HTML web page (`/volumes/nginx/html.conf`) whose content (`/volumes/html/index.html`) is shared with the `jaschac/nginx` container itself.

```bash
$ tree -h volumes
volumes/
├── [4.0K]  html
│   └── [  89]  index.html
└── [4.0K]  nginx
    └── [ 168]  html.conf

# the content being served
$ cat volumes/html/index.html
<html>
<header><title>This is title</title></header>
<body>
Hello world
</body>
</html>

# fire up the container
$ sudo docker run --name nginx -v $(pwd)/volumes/html/index.html:/var/www/html/index.html -v $(pwd)/volumes/nginx/html.conf:/etc/nginx/sites-enabled/html.conf -d jaschac/nginx:latest

# get the IP of the container
$ sudo docker inspect nginx

# query it
$ curl 172.17.0.2
<html>
<header><title>This is title</title></header>
<body>
Hello world
</body>
</html>
```

As a second, more complex example, let's reproduce the [example](https://github.com/jaschac/dockercompose-nginx-gunicorn-django-memcached) of a multi-container application that deploys an Nginx web server serving a Django application, supported by Memcached, through the Gunicorn Web Server Gateway Interface HTTP Server. We are going to replace the standard Nginx container with `jaschac/nginx`. The key point here is to make sure the vhost configuration file refers to Gunicorn through its linked name.

```bash
$ tree -h volumes/
volumes/
├── [4.0K]  django
│   └── [4.0K]  djsonizer
│       ├── [ 36K]  db.sqlite3
│       ├── [4.0K]  djsonizer
│       │   ├── [   0]  __init__.py
│       │   ├── [ 161]  __init__.pyc
│       │   ├── [2.6K]  settings.py
│       │   ├── [2.9K]  settings.pyc
│       │   ├── [1.1K]  urls.py
│       │   ├── [1.1K]  urls.pyc
│       │   ├── [4.0K]  wordslen
│       │   │   ├── [  63]  admin.py
│       │   │   ├── [ 227]  admin.pyc
│       │   │   ├── [   0]  __init__.py
│       │   │   ├── [ 170]  __init__.pyc
│       │   │   ├── [4.0K]  migrations
│       │   │   │   ├── [   0]  __init__.py
│       │   │   │   └── [ 181]  __init__.pyc
│       │   │   ├── [  57]  models.py
│       │   │   ├── [ 224]  models.pyc
│       │   │   ├── [  60]  tests.py
│       │   │   ├── [1.7K]  views.py
│       │   │   └── [1.6K]  views.pyc
│       │   ├── [ 395]  wsgi.py
│       │   └── [ 622]  wsgi.pyc
│       └── [ 252]  manage.py
└── [4.0K]  nginx
    └── [ 186]  gunicorn1.conf

# the vhost configuration file
server {
        listen 0.0.0.0:80;
        server_name gunicorn1.lostinmalloc.com;
        location / { 
                    proxy_pass http://gunicorn1:8001;
                      }
}

$ sudo docker run --name memcached1 -p 11211 -d memcached
$ sudo docker run -p 8001 --name gunicorn1 --link memcached1:memcached -v $PWD/volumes/django/djsonizer/:/var/www/webapp:ro -d jaschac/gunicorn-django
$ sudo docker run --name nginx -v $(pwd)/volumes/nginx/gunicorn1.conf:/etc/nginx/sites-enabled/gunicorn1.conf --link gunicorn1:gunicorn1 -d jaschac/nginx:latest

$ sudo docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                      NAMES
4d05ca481692        jaschac/nginx:latest        "/usr/local/sbin/setu"   4 seconds ago       Up 3 seconds        80/tcp, 443/tcp            nginx
9b8ad9901f8a        jaschac/gunicorn-django   "/bin/sh -c 'sh setup"   6 minutes ago       Up 6 minutes        0.0.0.0:32769->8001/tcp    gunicorn1
b73fdb8ad23c        memcached                 "/entrypoint.sh memca"   7 minutes ago       Up 7 minutes        0.0.0.0:32768->11211/tcp   memcached1

$ curl 172.17.0.4/hello/
{"cached": false, "word": "hello", "len": 5, "cached_by": ""}
$ curl 172.17.0.4/hello/
{"cached": true, "word": "hello", "len": 5, "cached_by": {"ip": "172.17.0.2", "hostname": "9b8ad9901f8a"}}
```

## Limitations
None, apart what has been mentioned in the [Description](#Description) section.

## Contact
You can contact me through:

  - The [GitHub page](https://github.com/jaschac/docker-nginx) of `jaschac-nginx`.
  - [Linkedin](https://es.linkedin.com/in/jaschacasadio).

Please feel free to report any bug and suggest new features/improvements.
