#!/bin/sh
# keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#trap 'echo "$(date): \"${last_command}\" command filed with exit code $?." >> $APP_LOG' EXIT

#set -x # for debugging

### BEGIN INIT INFO
# Provides:           @@@APPNAME@@@
# Required-Start:     $syslog $remote_fs
# Required-Stop:      $syslog $remote_fs
# Default-Start:      2 3 4 5
# Default-Stop:       0 1 6
### END INIT INFO

USER=root
#CONTAINER_ENGINE=podman
#COMPOSE_ENGINE=podman-compose
APP_NAME="@@@APPNAME@@@"
APP_HOME="/opt/plcnext/appshome"
APP_ID="@@@APPIDENTIFIER@@@"

##________Usefull environment variables________##

export APP_UNIQUE_NAME="@@@APPNAME@@@_@@@APPIDENTIFIER@@@" # unique AppName to use
export APP_PATH="/opt/plcnext/apps/${APP_ID}" # mountpoint for ro app file
export APP_TMP_PATH="/var/tmp/appsdata/${APP_ID}" # app temporary data storage
export APP_DATA_PATH="${APP_HOME}/data/${APP_ID}" # app persistent data storage
export APP_LOG="${APP_DATA_PATH}/${APP_NAME}.log" # logfile
export CONFIGFILE_PATH="/opt/plcnext/config/System/Um/Modules"
export MODEL_NAME=$(uname -n)
export OTAC_LICENSE="/opt/plcnext/otac/license"
##________APP configuration________##

# specify image archives and their accociated IDs in an array
# IMAGES[<image_ID>]=<image_archive>

# add all volumes to make them accessible to the container users and PLCnext admin (IDs 1002:1002)
# Space separated list e.g. VOLUMES=("${APP_DATA_PATH}/test1" "${APP_DATA_PATH}/test2")
declare -a VOLUMES=( "${APP_DATA_PATH}/www" )

##________Do not change the code below!________##

start () 
{
  if [ ! -e "$APP_LOG"  ]
  then
    touch $APP_LOG
  fi
  echo "$(date): Executing start()" >> $APP_LOG
################################################################################################################
##	Authentication.modules.config" 
  if [ ! -e "${CONFIGFILE_PATH}/Authentication.modules.config"  ]
  then
    echo "$(date): Creating  ${CONFIGFILE_PATH}/Authentication.modules.config" >> $APP_LOG
    cp -p ${APP_PATH}/AuthenticationProvider/config/Authentication.modules.config ${CONFIGFILE_PATH}
  fi
    
	
##	UmModuleEx.config
  if [ ! -e "${CONFIGFILE_PATH}/UmModuleEx.config"  ]
  then
    echo "$(date): Creating  ${CONFIGFILE_PATH}/UmModuleEx.config" >> $APP_LOG
    cp -p ${APP_PATH}/AuthenticationProvider/config/UmModuleEx.config ${CONFIGFILE_PATH}
  fi
  
##	user script
  echo "$(date): Creating  /opt/plcnext/userScript" >> $APP_LOG
  cp -r ${APP_PATH}/userScript /opt/plcnext
  
  
  echo "$(date): This model is ${MODEL_NAME}" >>$APP_LOG
  if [ "$MODEL_NAME" = "epc1502" ] || [ "$MODEL_NAME" = "EPC1502" ]
  then
	sed -i "s/<!--MODULE-->/libOTACauthClient-epc1502.so/gi" ${CONFIGFILE_PATH}/Authentication.modules.config
  elif [ "$MODEL_NAME" = "epc1522" ] || [ "$MODEL_NAME" = "EPC1522" ]
  then
	sed -i "s/<!--MODULE-->/libOTACauthClient-epc1522.so/gi" ${CONFIGFILE_PATH}/Authentication.modules.config
  elif [ "$MODEL_NAME" = "axcf2152" ] || [ "$MODEL_NAME" = "AXCF2152" ]
  then
	sed -i "s/<!--MODULE-->/libOTACauthClient-axcf2152.so/gi" ${CONFIGFILE_PATH}/Authentication.modules.config
  elif [ "$MODEL_NAME" = "axcf3152" ] || [ "$MODEL_NAME" = "AXCF3152" ]
  then
	sed -i "s/<!--MODULE-->/libOTACauthClient-axcf3152.so/gi" ${CONFIGFILE_PATH}/Authentication.modules.config
  elif [ "$MODEL_NAME" = "axcf1152" ] || [ "$MODEL_NAME" = "AXCF1152" ]
  then
	sed -i "s/<!--MODULE-->/libOTACauthClient-axcf1152.so/gi" ${CONFIGFILE_PATH}/Authentication.modules.config
  else
	echo "$(date): ERROR=This model is not supported." >>$APP_LOG
  fi
  
  if [ ! -d ${OTAC_LICENSE} ]; then
    mkdir -p "${OTAC_LICENSE}"
	touch "${OTAC_LICENSE}/swidchauthclient.lic"
	chown 1002:1002 "${OTAC_LICENSE}/swidchauthclient.lic"
  else
	touch "${OTAC_LICENSE}/swidchauthclient.lic"
	chown 1002:1002 "${OTAC_LICENSE}/swidchauthclient.lic"
  fi
  
  ################################################################################################################
  # When start() is executed then 
  # either 
  #   the image is not loaded and the container not started.
  #   Then load the docker image from the app directory and run container with 
  #   restart option to start it again after each boot of the controller.
  # or 
  #   the container is already loaded into the container cache. 
  #   It will be started by the container engine automatically.
 
  # copy user configuration file to the app persistent storage if needed
  

  # write Podman events to syslog
  logger -f /run/libpod/events/events.log
  rm -f /run/libpod/events/events.log
}

stop ()
{
  echo "$(date): Executing stop()" >> $APP_LOG
  # stop() is called when App is stopped by the AppManager e.g. via WBM
  # in this case the container needs to be stopped and removed from 
  # the container cache. The goal is to keep the controller clean.
  # stop() is also called when the system will shutdown.
  # In this case the container should not be removed. 
  # The container should just be started when the controller starts up again.

    # Distinguish whether the controller is in shutdown phase
    # if not shutdown then the app is explicitly stopped -> remove container and image
  currentRunlevel=$(runlevel | cut -d ' ' -f2)
  echo "$(date): current runlevel=${currentRunlevel}" >> $APP_LOG

	
  echo "$(date): Remove ${CONFIGFILE_PATH}/Authentication.modules.config" >> $APP_LOG
  rm ${CONFIGFILE_PATH}/Authentication.modules.config
  echo "$(date): Remove /opt/plcnext/userScript" >> $APP_LOG
  rm -r /opt/plcnext/userScript
  echo "$(date): stop() finished" >> $APP_LOG
  
  
  echo "$(date): stop() finished" >> $APP_LOG
  # write Podman events to syslog
  logger -f /run/libpod/events/events.log
  rm -f /run/libpod/events/events.log
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
esac
