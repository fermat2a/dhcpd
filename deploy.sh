#!/bin/bash

if [ ! -e dhcpd-omapi.conf ] ; then
  echo generating omapi key
  rm Komapi_key.*
  ssh root@dhcp1 rm Komapi_key.*
  ssh root@dhcp1 dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 512 -n HOST omapi_key && \
  scp "root@dhcp1:Komapi_key.*.private" . && \
  ssh root@dhcp1 rm Komapi_key.* ||
  exit
  SECRET=`grep ^Key: Komapi_key.*.private | cut -d \  -f 2`
  echo "key omapi_key {" > dhcpd-omapi.conf
  echo "     algorithm hmac-md5;" >> dhcpd-omapi.conf
  echo "     secret ${SECRET};" >> dhcpd-omapi.conf
  echo "}" >> dhcpd-omapi.conf
  rm Komapi_key.*
fi

scp *.conf root@dhcp1:/etc/dhcp/ && \
ssh root@dhcp1 systemctl restart isc-dhcp-server && \
scp *.conf root@dhcp2:/etc/dhcp/ && \
ssh root@dhcp2 systemctl restart isc-dhcp-server && \
echo successfully deployed and restarted

