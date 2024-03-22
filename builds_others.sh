##########
# Python #
##########

# En caso de correrlo en mac o linux donde existen los comandos id y whoami se puede crear la imagen y ejecutarla de la forma
docker build -t python_dev --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.python .

docker run -ti --name ej_python \
    -v "$PWD/src":"/home/$(whoami)/src" \
    python_dev

# En caso de correro en windows, podemos omitir los datos en el momento de contruir la imagen
docker build -t python_dev --force-rm \
    -f Dockerfile.python .

# Pero al momento de ejectuarla si debemo poner el path absoluto donde esta la carpeta que vamos a montar dentro del docker
docker run -ti --name ej_python \
    -v "$PWD/src":"/home/develop/src" \
    python_dev

########
# Java #
########

docker build -t java_dev --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.debian.java .

docker build -t java_dev --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.ubuntu.java .

docker run -ti --name ej_java -v "$PWD/src":"/home/$(whoami)/src" java_dev
