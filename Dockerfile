## clone/tar (FIXME not working with clone-* for source)
FROM alpine:3.15
ARG source="nongnu"
## vv NOTE removing automake and libtool from this list made image to be 45MB
ARG pkgs="automake libtool make autoconf file g++ git tzdata bash"
ARG versions="echo -e \"\$(grep '^PRETTY' /etc/os-release | sed 's/.\+=\"\(.\+\)\"/\1/')\\n\$(bash --version | sed '1q;d')\\n\$(jdate --version | xargs)\\n\$(jdate)\""
ARG prompt="PS1=\"\[\e[0;49;32m\]\u\[\e[0m\]\[\e[0;49;90m\]@\[\e[0m\]\[\e[0;49;34m\]\w\[\e[0m\] \""
ARG script=/tmp/install-jcal
ARG username="jdate"
ARG bashrc_file=/home/"$username"/.bashrc
ADD https://raw.githubusercontent.com/davoudarsalani/scripts/master/install-jcal "$script"
RUN set -x && \
    apk add --no-cache $pkgs && \
    \
    sed -i '/ldconfig/d' "$script" && \
    sed -i '/INSTALLING-DEPENDENCIES::START/,/INSTALLING-DEPENDENCIES::END/d' "$script" && \
    ## vv NOTE downloads $source version:
    # sed -i 's|) dl_xtract.*|) dl_xtract "https://www.dl.davoudarsalani.ir/DL/Temp/${source}-jcal-latest.tar.gz" ;;|g' "$script" && \
    chmod +x "$script" && \
    "$script" "$source" && \
    \
    adduser --uid 1001 --shell /bin/bash --disabled-password "$username" && \
    \
    printf '%s\n' "$versions" >> "$bashrc_file" && \
    printf '%s\n' "$prompt" >> "$bashrc_file" && \
    chown "$username" "$bashrc_file" && \
    \
    cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
    printf 'Asia/Tehran\n' > /etc/timezone && \
    \
    apk del ${pkgs/bash} && \
    rm -v "$script" && \
    rm -rfv /tmp/tmp* && \
    unset source pkgs versions prompt script bashrc_file && \
    set +x
USER "$username"
WORKDIR /home/"$username"
CMD bash

# docker build --tag jcal . && docker image ls -a
# docker run --rm -t jcal jdate
# ------------------------------------------------------------------------------------
# docker rm -f $(docker ps -aq); docker rmi -f $(docker image ls -aq)
# ------------------------------------------------------------------------------------
## jdatetime (59.8MB)
# FROM python:3.10-alpine3.15
# ARG versions="echo -e \"\$(grep '^PRETTY' /etc/os-release | sed 's/.\+=\"\(.\+\)\"/\1/')\\n\$(python --version)\\njdatetime \$(python -c \"import jdatetime; print(jdatetime.__VERSION__)\")\\n\$(python -c \"import jdatetime; print(jdatetime.datetime.now())\")\""
# ARG prompt="PS1=\"\[\e[0;49;32m\]\u\[\e[0m\]\[\e[0;49;90m\]@\[\e[0m\]\[\e[0;49;34m\]\w\[\e[0m\] \""
# ARG username="jdatetime"
# ARG bashrc_file=/home/"$username"/.bashrc
# ARG startup_file=/home/"$username"/python_startup.py
# RUN set -x && \
#     apk add --no-cache bash && \
#     \
#     adduser --uid 1001 --shell /bin/bash --disabled-password "$username" && \
#     \
#     printf 'import jdatetime\n' >> "$startup_file" && \
#     printf 'print("+++ jdatetime imported")\n' >> "$startup_file" && \
#     chown "$username" "$startup_file" && \
#     chmod +x "$startup_file" && \
#     \
#     printf '%s\n' "$versions" >> "$bashrc_file" && \
#     printf '%s\n' "$prompt" >> "$bashrc_file" && \
#     printf 'export PYTHONSTARTUP="$HOME"/python_startup.py\n' >> "$bashrc_file" && \
#     chown "$username" "$bashrc_file" && \
#     \
#     cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
#     printf 'Asia/Tehran\n' > /etc/timezone && \
#     \
#     pip install --upgrade --no-cache-dir --disable-pip-version-check pip jdatetime && \
#     \
#     apk del tzdata && \
#     unset versions prompt bashrc_file startup_file && \
#     set +x
# USER "$username"
# WORKDIR /home/"$username"
# CMD bash

# docker build --tag jcal . && docker image ls -a
# docker run --rm -t jcal python -c "import jdatetime; print(jdatetime.datetime.now().strftime('%Y %H:%M'))"
