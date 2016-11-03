#!/bin/bash

appname=$1

if [ $# -ne 1 ]; then
  echo "Usage: install_oauth_proxy.sh appname"
fi

set -e

dir=$(mktemp -d)
dir=/tmp/oauth
mkdir -p $dir
trap 'rm -rf $dir' EXIT INT TERM

urn=`oc get route ${appname} -o jsonpath='{.spec.host}'`

if ! oc get secret oauth-proxy >/dev/null 2>&1; then
    openshift admin ca create-signer-cert  \
      --key="${dir}/ca.key" \
      --cert="${dir}/ca.crt" \
      --serial="${dir}/ca.serial.txt" \
      --name="$1-$(date +%Y%m%d%H%M%S)"

    openshift admin ca create-server-cert  \
      --key=$dir/proxy.key \
      --cert=$dir/proxy.crt \
      --hostnames=oauth-proxy \
      --signer-cert="$dir/ca.crt" --signer-key="$dir/ca.key" --signer-serial="$dir/ca.serial.txt"

    cat <<-EOF >$dir/server-tls.json
	// See for available options: https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener
	tls_options = {
		ciphers: 'kEECDH:+kEECDH+SHA:kEDH:+kEDH+SHA:+kEDH+CAMELLIA:kECDH:+kECDH+SHA:kRSA:+kRSA+SHA:+kRSA+CAMELLIA:!aNULL:!eNULL:!SSLv2:!RC4:!DES:!EXP:!SEED:!IDEA:+3DES',
		honorCipherOrder: true
	}
	EOF

    # generate proxy session
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 200 | head -n 1 > "$dir/session-secret"
    # generate oauth client secret
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1 > "$dir/oauth-secret"

    echo "Creating secrets"
    oc secrets new oauth-proxy \
        oauth-secret=$dir/oauth-secret \
        session-secret=$dir/session-secret \
        server-key=$dir/proxy.key \
        server-cert=$dir/proxy.crt \
        server-tls.json=$dir/server-tls.json
    echo "Attaching secrets to service accounts"
    oc secrets add serviceaccount/default \
                   oauth-proxy
fi

if ! oc get oauthclient ${appname}-oauth-proxy >/dev/null 2>&1; then
  cat <<-EOF | oc create -f -
	{
  	  "kind": "OAuthClient",
    	  "apiVersion": "v1",
	  "metadata": {
            "name": "${appname}-oauth-proxy"
	  },
  	  "secret": "`cat ${dir}/oauth-secret`",
    	  "redirectURIs": [
	    "https://${urn}"
  	  ]
	}
	EOF
fi
