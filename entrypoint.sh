#!/usr/bin/env bash

[ -z "$TFTPD_PORT" ] && { echo >&2 "TFTPD_PORT must be set"; exit 1; }
[ "$TFTPD_PORT" -eq 0 ] && { echo >&2 "TFTPD_PORT must not be 0!"; exit 1; }

TFTPD_LOGLEVEL=${TFTPD_LOGLEVEL:-"notice"}
TFTPD_PATH=${TFTPD_PATH:-"/tftpd"}

WRITABLE_OPT=""
if [[ "$TFTPD_ENABLE_WRITABLE" == "yes" ]]; then
  WRITABLE_OPT=",writable"
fi

OPTS="ftp=0,tftp=${TFTPD_PORT}${WRITABLE_OPT}"

exec uftpd -o "$OPTS" -l "$TFTPD_LOGLEVEL" "$TFTPD_PATH" -n
