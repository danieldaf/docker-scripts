##01
docker build -t ejemplo01 --force-rm -f Dockerfile.01 .
docker run -ti --name ej01 --rm ejemplo01

# mostramos lo simple que es crear una imagen, partiendo desde una ya de base
# en este caso un debian minimo con node v20
# Al iniciarla el intereprete es el de node

##02
# mostramos como modificamos la imagen para que reemplaze el comando por defecto, del interprete de node
# por el de bash
docker build -t ejemplo02 --force-rm -f Dockerfile.02 .
docker run -ti --name ej02 --rm ejemplo02

# mosramos que el usuario por defecto es root, lo cual no seria lo ideal para un entorno de desarrollo

##03
# La imagen de base que estamos usando ya tiene un usuario creado, de nombre 'node'
# Lo utilizamo como usuario por defecto
docker build -t ejemplo03 --force-rm -f Dockerfile.03 .
docker run -ti --name ej03 --rm ejemplo03

# Resaltamos que el los archivos creaos en el contenedor estan dentro de el lo cual no es lo mas comodo
# para editarlos desde afuera

##04
# Introducimos el concepto de volumenes y mapeamos la carpeta de nuestro codigo en la carpeta src dentro del contenedor
#
# Agregamos la utlidad tini, que es un inicializador de serivicios eficiente para contenedores de docker
# Su principal ventaja es la liberacion de recursos mas eficiente al finalizar los servicios

docker build -t ejemplo04 --force-rm -f Dockerfile.04 .
docker run -ti --name ej04 -v "$PWD/src":/home/node --rm ejemplo04

##05
# Mostramos que no se pueden trabajar bien los archivos dentro del contenedor porque el usuario y grupo de los arhivos 
# fuera del contenedor no coinciden con el usuario 'node' del contenedor
# Para ello modificamos el dockerfile para crear el usuario dentro del contenedor  

docker build -t ejemplo05 --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.05 .
docker run -ti --name ej05 \
    -v "$PWD/src":"/home/$(whoami)/src" \
    ejemplo05

# Mostramos que el contenedor ya esta ejecutandose y finaliza cuando cerramos su terminal
# Resaltamos el parametro --rm dentro del docker run, que ahora no lo usamos

docker ps
docker ps -a

# Mostramos como volvemos a ejecutar, esta vez no construyendo un contenedor a partir de una imagen, 
# sino ejecutando el contenedor previamente creado 

docker start ej05
docker ps

# Mostramos como capturar la terminal por defecto del contenedor
docker attach ej05 
# Mostramos que capturandola via attach, siempre vemos la misma terminal. Y que finalizar una finaliza todo.

# Volvemos a iniciar el contenedor, capturamos la terminal y iniciamos otra terminal
docker start ej05
docker attach ej05 
docker exec -it ej05 /bin/bash
# mostramos que finalizar la segunda terminal no finaliza el contenedor

## En este punto tenemos la imagen base para trabajar con proyectos de node.
# Supongamos que queremos hacer un proyecto de node entonces precisamos instalarlo

#https://angular.io/cli
npm install -g @angular/cli

# Mostramos que falla porque el usuario no tiene permisos para instalar un paquete de node global.
# Para ello precisamos 'sudo'. Que solo debemos usarlo para contenedores con fines de desarrollo.

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
ng new app-angular --defaults --skip-install
# Hcemos npm install 
npm install
# Compilamos y levantamos la app en modo de desarrollo
ng build 
ng serve

# Vemos que se levanta en el puerto 4200 de la ip localhost del contenedor
# Y que no es acccesible fuera del contenedor, por lo que no podemos ver la app desde nuestro browser.

##07
# Mosramos que precisamos indicar el puerto a exportar
# Y de paso, como buena practica, incorporamos la instalacion de node al dockerfile
# Resaltamos la ubicacion donde hacemos la instalacion para que se ejecute como root (sin sudo)
# Antes obtenemos la version de angular que queremos dejar fija en la imagen. 
# Por defecto instalamos la ultima, pero sera mejor especificarla en el dockerfile, de lo contrario
# cuando se construya la imagen siempre se instalara la ultima version
#sudo npm install -g @angular/cli@17.3.0

docker build -t ejemplo07 --force-rm \
    --build-arg UID="$(id -u)" \
    --build-arg GID="$(id -g)" \
    --build-arg UNAME="$(whoami)" \
    -f Dockerfile.07 .
docker run -ti --name ej07 \
    -v "$PWD/src":"/home/$(whoami)/src" \
    -p 14200:4200 \
    ejemplo07

ng serve
# Mostramos que aun levantando el servidor de angular no nos podemos conectar.
# Porque el servidor de angular por defecto solo esta publicandose en la ip localhost del contenedor
# Y precisamos que se conecta a su ip local 
ng serve --host 0.0.0.0

# Mostramos que ya podemos ver la app corriendo desde fuera del contenedor
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