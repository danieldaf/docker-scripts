FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tini openjdk-21-jdk-headless sudo

ARG UID=1000
ARG GID=1000
ARG UNAME=develop

RUN if [ "${UID}" = "1000" ] && [ "${GID}" = "1000" ] ; then \
        sed -i 's_node:x:1000:1000::/home/node:/bin/bash_node:x:2000:2000::/home/node:/bin/bash_' /etc/passwd && \
        sed -i 's_node:x:1000:_node:x:2000:_' /etc/group ; \
    elif [ "${UID}" = "1000" ] ; then \
        sed -i 's_node:x:1000:1000::/home/node:/bin/bash_node:x:2000:1000::/home/node:/bin/bash_' /etc/passwd ; \
    elif [ "${GID}" = "1000" ]; then \
        sed -i 's_node:x:1000:_node:x:2000:_' /etc/group ; \
    fi
RUN groupadd -g ${GID} -o ${UNAME} && \
    useradd -m -u ${UID} -N -g ${GID} -o -s /bin/bash ${UNAME}

RUN adduser ${UNAME} sudo && \
    passwd -d ${UNAME}

RUN echo '#!/bin/bash \n\n\
    alias ls="ls --color=auto" \n\
    ' > /home/${UNAME}/.bash_aliases

RUN mkdir /home/${UNAME}/src
WORKDIR /home/${UNAME}/src
USER ${UNAME}

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash"]