FROM alpine:latest AS compile
RUN apk update && apk upgrade && apk add \
  cppunit-dev g++ gcc krb5-dev libc-dev libgsasl-dev make musl-dev openldap-clients openldap-dev perl \
  samba-dev samba-winbind samba-winbind-clients && rm -rf /var/cache/apk
ARG SQUID_MAJOR_VERSION=6
ARG SQUID_MINOR_VERSION=6
RUN wget http://www.squid-cache.org/Versions/v${SQUID_MAJOR_VERSION}/squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}.tar.gz && tar zvxf squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}.tar.gz
WORKDIR /squid-${SQUID_MAJOR_VERSION}.${SQUID_MINOR_VERSION}
RUN ./configure && time make -j 4 && make install

FROM alpine:latest
RUN apk update && apk add gcc krb5-dev libstdc++ && rm -rf /var/cache/apk
COPY --from=compile /usr/local/squid/bin/ /usr/local/bin/
COPY --from=compile /usr/local/squid/sbin/ /usr/local/bin/
COPY --chown=squid:squid --from=compile /usr/local/squid/var/ /usr/local/squid/var/
COPY --from=compile /usr/local/squid/libexec/ /usr/local/squid/libexec/
COPY --from=compile /usr/local/squid/share/ /usr/local/squid/share/
COPY --from=compile /usr/local/squid/etc/ /usr/local/squid/etc/
USER squid
EXPOSE 3128
CMD ["squid", "--foreground"]
