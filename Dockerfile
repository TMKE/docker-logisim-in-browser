
FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04

# install XPRA: https://xpra.org/trac/wiki/Usage/Docker 
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y wget gnupg2 && \
    wget -O - http://winswitch.org/gpg.asc | apt-key add - && \
    echo "deb http://winswitch.org/ bionic main" > /etc/apt/sources.list.d/xpra.list && \
    apt-get update && \
    apt-get install -y xpra xvfb xterm && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*
    
# non-root user
RUN adduser --disabled-password --gecos "VICE_User" --uid 1000 user

# install all X apps here
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y firefox && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/user/1000/xpra
RUN mkdir -p /run/xpra
RUN chown user:user /run/user/1000/xpra
RUN chown user:user /run/xpra

# Install iCommands
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - \
    && echo "deb https://packages.irods.org/apt/ xenial main" | tee /etc/apt/sources.list.d/renci-irods.list \
    && apt-get update && apt-get install -y irods-icommands

RUN apt-get install -y logisim

USER user

ENV DISPLAY=:100

WORKDIR /home/user

EXPOSE 9876

CMD xpra start --bind-tcp=0.0.0.0:9876 --html=on --start-child="/usr/bin/java -jar /usr/bin/logisim" --exit-with-children=no --daemon=no --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no :100


