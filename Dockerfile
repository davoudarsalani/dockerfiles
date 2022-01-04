## jdatetime
FROM python:3.10-alpine3.15
RUN apk add --no-cache bash && \
    cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
    printf 'Asia/Tehran\n' > /etc/timezone && \
    pip3 install --upgrade --no-cache-dir --disable-pip-version-check pip jdatetime  ## pip3/pip install
CMD bash
# ------------------------------------------------------------------------------------
# docker build -f py --tag jcal:jdatetime3.7.0-python3.10-alpine3.15 .

## no CNT
# docker run --rm jcal:jdatetime3.7.0-python3.10-alpine3.15 python -c "import jdatetime; print(jdatetime.datetime.now().strftime('%Y %H:%M'))"

## CNT
# docker run -d -t --name cnt jcal:jdatetime3.7.0-python3.10-alpine3.15
# docker exec -t cnt python -c "import jdatetime; print(jdatetime.datetime.now().strftime('%Y %H:%M'))"




## clone/tar (FIXME not working with clone-* options)  265MB
##   vv 3.15 didn't work
FROM alpine:3.12
RUN apk add --no-cache bash git tzdata \
    automake libtool make autoconf file g++
    # if necessary: build-base gcc
    # not found: build-essential libjalali-dev
SHELL ["/bin/bash", "-c"]
RUN cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime && \
    printf 'Asia/Tehran\n' > /etc/timezone && \
    wget -q https://raw.githubusercontent.com/davoudarsalani/scripts/master/install-jcal && \
    chmod +x ./install-jcal && \
    sed -i '/ldconfig/d' ./install-jcal && \
    sed -i 's|mktemp --directory|mktemp -d|' ./install-jcal && \
    sed -i 's|^\(\./autogen.*\)|bash -c "\1"|' ./install-jcal && \
    sed -i 's|^\(\./configure.*\)|bash -c "\1"|' ./install-jcal && \
    sed -i 's|^ *\(make.*\)|bash -c "\1"|' ./install-jcal && \
    ./install-jcal 'gnu' && \
    rm ./install-jcal && \
    rm -rf /tmp/tmp*
CMD bash
# --disable-dependency-tracking
# libtoolize --force ; aclocal ; autoheader ; automake --force-missing --add-missing ; autoconf ; ./configure ; make
