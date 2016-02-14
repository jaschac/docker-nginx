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
@TODO

## Limitations
@TODO

## Contact
You can contact me through:

  - The [GitHub page](https://github.com/jaschac/docker-nginx) of `jaschac-nginx`.
  - [Linkedin](https://es.linkedin.com/in/jaschacasadio).

Please feel free to report any bug and suggest new features/improvements.

