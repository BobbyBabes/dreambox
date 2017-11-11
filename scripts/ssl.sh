#!/bin/bash
#
# Create the SSL certificate, then finish setup
#
open_ssl_conf='/usr/lib/ssl/dreambox-openssl.cnf'

# REVIEW Look into executing a ruby script to output the DNS Hosts file

# REVIEW This should no longer be necessary
# Create an array from the hosts string
# IFS=',' read -r -a HOST_LIST <<< "${hosts}"
# Use the first host as the main host
# HOST="${HOST_LIST[0]}"

# Check for a saved certificate and key
if [[ -r "/vagrant/certs/${name}.key" && -r "/vagrant/certs/${name}.crt" ]]; then
  # Use the saved certs
  echo "Using saved certs from /vagrant/certs/"
  cp -f /vagrant/certs/"${name}".* /usr/local/apache2/conf/
else
  # REVIEW This should no longer be necessary
  # Build the hosts DNS strings
  # for (( i=1; i<=${#HOST_LIST[@]}; i++ )); do
  #   echo "DNS.${i} = ${HOST_LIST[$i-1]}" >> "${open_ssl_conf}"
  # done

  # TODO `cat` the DNS Hosts file into `open_ssl_conf`
  if ! grep -q "# Dreambox config" $open_ssl_conf ]]; then
    # cat $hosts_file >> $open_ssl_conf
    bash -c "cat ${hosts_file} >> ${open_ssl_conf}"
  fi

  # Create the certificate
  openssl req \
    -x509 -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -extensions v3_req \
    -subj "/C=US/ST=Washington/L=Seattle/O=IT/CN=${host}/" \
    -keyout "/usr/local/apache2/conf/${name}.key" \
    -out "/usr/local/apache2/conf/${name}.crt" \
    -config "${open_ssl_conf}";

  # Create the certs directory
  [[ ! -d /vagrant/certs ]] && mkdir /vagrant/certs
  # Save these for next time
  cp -f /usr/local/apache2/conf/"${name}".* /vagrant/certs
fi

if [[ $? -lt 1 ]]; then
  echo -e "SSL certificate created: ${name}.crt\n"
else
  echo -e "SSL setup error..."
fi
