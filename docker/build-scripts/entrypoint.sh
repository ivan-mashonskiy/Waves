#!/bin/bash
shopt -s nullglob
NETWORKS="mainnet testnet stagenet custom"

logEcho() {
  echo $1 | gosu waves tee -a /var/log/waves/waves.log
}

if [[ ! -f "$WAVES_CONFIG" ]]; then
  logEcho "Custom '$WAVES_CONFIG' not found. Using a default one for '${WAVES_NETWORK,,}' network."
  if [[ $NETWORKS == *"${WAVES_NETWORK,,}"* ]]; then
    # don't use indentation for heredoc because of its restrictions
eval "cat <<EOF
$(</etc/waves/waves.conf.template)
EOF" 2> /dev/null > $WAVES_CONFIG
  else
    echo "Network '${WAVES_NETWORK,,}' not found. Exiting."
    exit 1
  fi
else
  echo "Found custom '$WAVES_CONFIG'. Using it."
fi

[ -n "${WAVES_WALLET_PASSWORD}" ] && JAVA_OPTS="${JAVA_OPTS} -Dwaves.wallet.password=${WAVES_WALLET_PASSWORD}"
[ -n "${WAVES_WALLET_SEED}" ] && JAVA_OPTS="${JAVA_OPTS} -Dwaves.wallet.seed=${WAVES_WALLET_SEED}"
JAVA_OPTS="${JAVA_OPTS} -Dwaves.directory=$WVDATA"

logEcho "Node is starting..."
logEcho "WAVES_HEAP_SIZE='${WAVES_HEAP_SIZE}'"
logEcho "WAVES_LOG_LEVEL='${WAVES_LOG_LEVEL}'"
logEcho "WAVES_NETWORK='${WAVES_NETWORK}'"
logEcho "JAVA_OPTS='${JAVA_OPTS}'"

JAVA_OPTS="-Dlogback.stdout.level=${WAVES_LOG_LEVEL}
  -XX:+ExitOnOutOfMemoryError
  -Xmx${WAVES_HEAP_SIZE}
  -Dlogback.file.directory=$WVLOG
  -Dconfig.override_with_env_vars=true
  ${JAVA_OPTS}"

exec gosu waves $WAVES_INSTALL_PATH/bin/waves "$WAVES_CONFIG"

