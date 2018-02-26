FROM alpine:latest

MAINTAINER Harsha Krishnareddy <c0mpiler@outlook.com>

ARG REQUIRE="sudo build-base"
RUN apk update && apk upgrade \
      && apk add --no-cache ${REQUIRE}

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk update && apk upgrade
RUN apk add --no-cache \
			build-base \
			gfortran \
			libffi-dev \
			ca-certificates \
			libgfortran \
			python3 \
			python2 \
			py-setuptools \
			py3-setuptools \
			py2-pip \
			bash \
      bash-doc \
      bash-completion \
			bzip2-dev \
			gcc \
			gdbm-dev \
			libc-dev \
			linux-headers \
			ncurses-dev \
			openssl \
			openssl-dev \
			pax-utils \
			readline-dev \
			sqlite-dev \
			tcl-dev \
			tk \
			tk-dev \
			zlib-dev \
			git \
      lapack-dev \
      libstdc++ \
      gfortran \
      g++ \
      make \
      python3-dev \
      python2-dev

  USER root
	RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
  RUN mkdir -p /tmp/build \
    && cd /tmp/build \
    && wget http://www.netlib.org/blas/blas-3.6.0.tgz \
    && wget http://www.netlib.org/lapack/lapack-3.6.1.tgz \
    && tar xzf blas-3.6.0.tgz \
    && tar xzf lapack-3.6.1.tgz \
    && chown -R root:root BLAS-3.6.0 \
    && chown -R root:root lapack-3.6.1 \
    && chmod -R 777 /tmp/build/BLAS-3.6.0 \
    && chmod -R 777 /tmp/build/lapack-3.6.1 \
    && cd /tmp/build/BLAS-3.6.0/ \
    && gfortran -O3 -std=legacy -m64 -fno-second-underscore -fPIC -c *.f \
    && ar r libfblas.a *.o \
    && ranlib libfblas.a \
    && mv libfblas.a /tmp/build/. \
    && cd /tmp/build/lapack-3.6.1/ \
    && sed -e "s/frecursive/fPIC/g" -e "s/ \.\.\// /g" -e "s/^CBLASLIB/\#CBLASLIB/g" make.inc.example > make.inc \
    && make lapacklib \
    && make clean \
    && mv liblapack.a /tmp/build/. \
    && cd / \
    && export BLAS=/tmp/build/libfblas.a \
    && export LAPACK=/tmp/build/liblapack.a

  RUN python3 -m pip --no-cache-dir install pip -U
  RUN python3 -m pip --no-cache-dir install scipy
  RUN python2 -m pip --no-cache-dir install pip -U
  RUN python2 -m pip --no-cache-dir install scipy
  #RUN apk del --purge -r build_dependencies
  RUN rm -rf /tmp/build
  RUN rm -rf /var/cache/apk/*

RUN apk --no-cache add boost-filesystem boost-system boost-program_options boost-date_time boost-thread boost-iostreams musl-utils boost-dev boost-python boost-python3 boost-graph boost boost-build

RUN python3 -m pip --no-cache-dir install seaborn
RUN python2 -m pip --no-cache-dir install seaborn

CMD ["/bin/ash"]
