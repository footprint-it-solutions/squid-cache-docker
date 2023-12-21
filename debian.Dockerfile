FROM debian:trixie-slim AS compile
RUN apt update && apt -y upgrade && apt install -y  \
  build-essential libcppunit-dev libkrb5-dev libgsasl-dev libldap-dev perl \
  samba-dev libwbclient-dev time wget && rm -rf /var/cache/apt
ARG SQUID_MAJOR_VERSION=6
ARG SQUID_MINOR_VERSION=6
RUN wget http://www.squid-cache.org/Versions/v${SQUID_MAJOR_VERSION}/squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}.tar.gz && tar zvxf squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}.tar.gz
WORKDIR /squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}
RUN ./configure && time make -j 4 && make install

FROM debian:trixie-slim
RUN apt update && apt install -y libkrb5-dev && rm -rf /var/cache/apt
RUN useradd -u 1000 -M squid
COPY --from=compile /usr/local/squid/bin/ /usr/local/bin/
COPY --from=compile /usr/local/squid/sbin/ /usr/local/bin/
COPY --chown=squid:squid --from=compile /usr/local/squid/var/ /usr/local/squid/var/
COPY --from=compile /usr/local/squid/libexec/ /usr/local/squid/libexec/
COPY --from=compile /usr/local/squid/share/ /usr/local/squid/share/
COPY --from=compile /usr/local/squid/etc/ /usr/local/squid/etc/
USER squid
EXPOSE 3128
CMD ["squid", "--foreground"]
