## clone/tar (FIXME not working with clone-* options)
FROM alpine:3.15
ARG script="/tmp/install-jcal" pkgs="automake libtool make autoconf file g++ git tzdata" source="nongnu"
ADD https://raw.githubusercontent.com/davoudarsalani/scripts/master/install-jcal "$script"
RUN apk add --no-cache bash $pkgs && \
    \
    cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
    printf 'Asia/Tehran\n' > /etc/timezone && \
    \
    sed -i '/ldconfig/d' "$script" && \
    chmod +x "$script" && \
    "$script" "$source" && \
    \
    apk del $pkgs && \
    \
    rm -v "$script" && \
    unset script pkgs source && \
    rm -rfv /tmp/tmp*
CMD bash
## alpine3.15 bash=5.1.8   8.21MB
## alpine3.12 bash=5.0.17  8.08MB
## alpine3.11 bash=5.0.11  7.88MB
## alpine3.10 bash=5.0.0   7.84MB

# docker build --tag jcal:nongnu-alpine3.15-bash5.1.8 . && docker image ls -a
# docker run --rm jcal:nongnu-alpine3.15-bash5.1.8 jdate

# --disable-dependency-tracking  **  libtoolize --force; aclocal; autoheader; automake --force-missing --add-missing; autoconf; ./configure
# ------------------------------------------------------------------------------------
## jdatetime
# FROM python:3.10-alpine3.15
# RUN apk add --no-cache bash && \
#     \
#     cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
#     printf 'Asia/Tehran\n' > /etc/timezone && \
#     \
#     pip3 install --upgrade --no-cache-dir --disable-pip-version-check pip jdatetime  ## pip3/pip install
# CMD bash
# docker build --tag jcal:jdatetime3.7.0-python3.10-alpine3.15 .

## no CNT:  docker run --rm jcal:jdatetime3.7.0-python3.10-alpine3.15 python -c "import jdatetime; print(jdatetime.datetime.now().strftime('%Y %H:%M'))"

## CNT:  docker run -d -t --name cnt jcal:jdatetime3.7.0-python3.10-alpine3.15
#        docker exec -t cnt python -c "import jdatetime; print(jdatetime.datetime.now().strftime('%Y %H:%M'))"
