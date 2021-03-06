#!/usr/bin/env bash

CSGO_HOME="/home/csgo"
CSGO_DATA="${CSGO_HOME}/data"
cd $CSGO_HOME

echo "Checking for updates..."
echo "INFO: This might take a while espacially for the first run!"
STEAMCMD_EXIT=-1
while
    test -n "${BETA}" && BETA_CMD="-beta ${BETA}"
    ./steamcmd.sh +login anonymous +force_install_dir ${CSGO_DATA} +app_update 740 ${BETA_CMD} +quit > /dev/null
    STEAMCMD_EXIT="$?"

    if [ "$STEAMCMD_EXIT" == "7" ]; then
        echo "FATAL: Not enough disk space!"
        exit 7;
    elif [ "$STEAMCMD_EXIT" == "8" ]; then
        echo "Retrying to update (steamcmd.sh exit status was ${STEAMCMD_EXIT})"
    fi

    [ "$STEAMCMD_EXIT" -eq "8" ]
do :;  done

# setting defaults
test -z "${MAP+x}" && MAP="de_dust2"
test -z "${GAME_MODE+x}" && GAME_MODE="COMPETITIVE"
test -z "${MAXPLAYERS+x}" && MAXPLAYERS="10"
test -z "${SERVER_IP+x}" && SERVER_IP="0.0.0.0"

test -n "${MAXPLAYERS}" && MAXPLAYERS_CMD="-maxplayers_override ${MAXPLAYERS}"
test -n "${WEB_API_KEY}" && WEB_API_KEY_CMD="-authkey ${WEB_API_KEY}"
test -n "${MAP}" && MAP_CMD="+map ${MAP}"
test -n "${GSLT}" && GSLT_CMD="+sv_setsteamaccount ${GSLT}"

if [ "$GAME_MODE" == "CASUAL" ]; then
    GAME_MODE_CMD="+game_type 0 +game_mode 0"
elif [ "$GAME_MODE" == "COMPETITIVE" ]; then
    GAME_MODE_CMD="+game_type 0 +game_mode 1"
elif [ "$GAME_MODE" == "ARMS_RACE" ]; then
    GAME_MODE_CMD="+game_type 1 +game_mode 0"
elif [ "$GAME_MODE" == "DEMOLITION" ]; then
    GAME_MODE_CMD="+game_type 1 +game_mode 1"
fi

echo "#######################################################"
echo "Starting up CS:GO Server..."

cd ${CSGO_HOME}
./data/srcds_run -game csgo -usercon -tickrate 128 +ip ${SERVER_IP} +net_public_adr ${SERVER_IP} ${MAXPLAYERS_CMD} ${WEB_API_KEY_CMD} ${MAP_CMD} ${GSLT_CMD} ${GAME_MODE_CMD} $@
