##01
docker build -t ejemplo01 --force-rm -f Dockerfile.01 .
docker run -ti --name ej01 --rm ejemplo01

##02
docker build -t ejemplo02 --force-rm -f Dockerfile.02 .
docker run -ti --name ej02 --rm ejemplo02

##03
docker build -t ejemplo03 --force-rm -f Dockerfile.03 .
docker run -ti --name ej03 --rm ejemplo03

##04
docker build -t ejemplo04 --force-rm -f Dockerfile.04 .
docker run -ti --name ej04 -v "$PWD/src":/home/node/src --rm ejemplo04

##05
docker build -t ejemplo05 --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.05 .
docker run -ti --name ej05 \
    -v "$PWD/src":"/home/$(whoami)/src" \
    ejemplo05

# El contenedor ej05 se finaliza pero no se destruye
docker ps -a

# Podemos volver a ejectuarlo con start
docker start ej05
# Y revisar que ahora aparece en el listado de contenedores en ejecucion
docker ps

# Para obtener acceso a la terminal del contenedor debemos usar attach
docker attach ej05 

# Volvemos a iniciar el contenedor, capturamos la terminal y iniciamos otra terminal
docker start ej05
docker attach ej05 
docker exec -it ej05 /bin/bash

## En este punto tenemos la imagen base para trabajar con proyectos de node.
# Supongamos que queremos hacer un proyecto de node entonces precisamos instalarlo

#https://angular.io/cli
npm install -g @angular/cli

# Falla porque precisamos correlo con 'sudo'. Que solo debemos usarlo para contenedores con fines de desarrollo.

##06
docker build -t ejemplo06 --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.06 .
docker run -ti --name ej06 \
    -v "$PWD/src":"/home/$(whoami)/src" \
    ejemplo06

# Instalamos la angular
sudo npm install -g @angular/cli
# Creamos el esqueleto de un app
ng new app-angular --defaults --skip-install --skip-git
# Hcemos npm install 
npm install
# Compilamos y levantamos la app en modo de desarrollo
ng build 
ng serve

##07
# Precisamos indicar el puerto a exportar
# Y como buena practica, incorporamos la instalacion de angular al dockerfile
#
# La version de angular que instalamos antes era la útima disponible:
#       sudo npm install -g @angular/cli
# Lo ideal seria fijar que version queres usar en nuestro entorno, en este caso la version de angular 17.3.0
# Para ello la instalacion por linea de comandos seria:
#       sudo npm install -g @angular/cli@17.3.0

docker build -t ejemplo07 --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.07 .
docker run -ti --name ej07 \
    -v "$PWD/src":"/home/$(whoami)/src" \
    -p 14200:4200 \
    ejemplo07

ng serve --host 0.0.0.0

# Ya podemos ver la app corriendo desde fuera del contenedor
# Y podemos compilarlo desde dentro del contenedor

# Teniendo el docker file ya actualizado, deberiamos incorporarlo como un archivo mas del proyecto y versionarlo en el git
# Cuando se tenga que modificar el contenedor, lo idal seria ir actuaizando el dockerfile.
# No osbtante, esto puede ser engorroso a veces, sino complicado caundo las personalizacion del contenedor es grande 
# o no sabemos bien como automatizarla.
# En ese caso no esta todo perdido, aún podemos ir versionando los cambios de la imagen final (aunque no seria esta lo 
# ideal, dado que estamos perdiendo el detalle de como se constuyo la imagen)

## Tenemos dos alternativas:
## commit
docker commit ej07 ej07-commited

## export / import
docker export -o docker-image-ej07.tar ej07
docker import docker-image-ej07.tar ej07-reimported

# La ventaja de tener el dockerfile actualiado es que esta versionado en el git, y es facil que alguien lo reconstruya.
# Podemos hacer los mismo con las imagenes, compartirlas por ejemplo a travez de github
# Mostrar la seccion de paquetes de gihub
# https://docs.github.com/es/packages/working-with-a-github-packages-registry/working-with-the-container-registry

## push & pull
docker login ghcr.io -u USERNAME
# Resaltar los permisos del token write:pakages read:packages delete:pacakges

docker tag ej07-commited:latest ghcr.io/danieldaf/ej07-commited:latest

docker push ghcr.io/danieldaf/ej07-commited:latest
docker pull ghcr.io/danieldaf/ej07-commited:latest
docker rmi ghcr.io/danieldaf/ej07-commited:latest