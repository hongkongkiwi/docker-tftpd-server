FROM debian:bullseye-slim

ARG TFTPD_GID=
ARG TFTPD_UID=
ARG LOCALE=en_US
ARG CHARSET=UTF-8
ARG DEBIAN_MIRROR=ftp.hk.debian.org

ENV TFTPD_PORT=69
# none, err, notice (default), info, debug
ENV TFTPD_LOGLEVEL=notice
ENV TFTPD_ENABLE_WRITABLE=yes
ENV TFTPD_PATH=/tftpd

VOLUME $TFTPD_PATH

EXPOSE $TFTPD_PORT

COPY entrypoint.sh /entrypoint.sh

RUN echo "Creating tftpd user/group" && \
    if [ -n "${TFTPD_GID}" ] && [ "${TFTPD_GID}" -eq "${TFTPD_GID}" ] 2>/dev/null; then groupadd -r -g ${TFTPD_GID} tftpd; else groupadd -r tftpd; fi && \
    if [ -n "${TFTPD_UID}" ] && [ "${TFTPD_UID}" -eq "${TFTPD_GID}" ] 2>/dev/null; then useradd -r -g tftpd -u ${TFTPD_UID} tftpd; else useradd -r -g tftpd tftpd; fi

RUN echo "Updating/Installing Packages" && \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list && \
    apt-get update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      bash \
      locales \
      gnupg2 

RUN echo "Adding package source for utftpd" && \
    curl -sS "https://deb.troglobit.com/pubkey.gpg" | apt-key add - && \
    echo "deb [arch=amd64] https://deb.troglobit.com/debian stable main" | tee /etc/apt/sources.list.d/troglobit.list && \
    echo "Installing uftpd" && \
    apt-get update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends uftpd && \
    uftpd -v

RUN echo "Setting up locale ${LOCALE}.${CHARSET}" && \
    localedef -i ${LOCALE} -c -f ${CHARSET} -A "/usr/share/locale/locale.alias" "${LOCALE}.${CHARSET}"

RUN echo "Setting up permissions" && \
    chmod 755 /entrypoint.sh

CMD ["bash", "entrypoint.sh"]
