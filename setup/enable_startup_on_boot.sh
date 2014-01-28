#!/bin/sh

# list you agents names here, space separated
AGENTS="<agent names>"
# full path of caboodle
CABOODLE="/your/caboodle/full/path/here"
# additional variables needed by the agent, for example ORACLE_HOME/LD_LIBRARY_PATH/...
#EXTRA_VAR="export ORACLE_HOME=/usr/lib/oracle/12.1/client64\nexport LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib"
# arguments for the daemon function, for example to run agents as another user
#DAEMON_ARGS="export DAEMON_ARGS=\"--user=<agents user>\""

[ "x$USER" != "xroot" ] && (echo "This script should be run as root."; exit 1)
[ ! -d "$CABOODLE/setup" ] && (echo "The $CABOODLE/setup directory doesn't exists."; exit 1)
# I choose to store the pid file inside the caboodle to avoid tampering /var/run with user-writable dirs
[ ! -d "$CABOODLE/var/run" ] && (echo "The $CABOODLE/var/run directory doesn't exists.\nCreate the directory with the correct user/permissions"; exit 1)

echo "Enabling startup on boot for agents $AGENTS of caboodle $CABOODLE."

cd $CABOODLE/setup

for i in $AGENTS
do
  echo -n "| Agent $i : "

  cp nodebrain.service /etc/init.d/$i >/dev/null 2>&1
  echo -n "/etc/init.d/$i "
  if [ $? == 0 ]; then
  	echo -n "OK - "
  else
  	echo -n "FAIL - "
  fi

  chkconfig --add $i >/dev/null 2>&1
  echo -n "chkconfig add "
  if [ $? == 0 ]; then
  	echo -n "OK - "
  else
  	echo -n "FAIL - "
  fi

  echo -e "CABOODLE=$CABOODLE\nAGENT=$i\n$EXTRA_VAR\n$DAEMON_ARGS" >/etc/sysconfig/$i
  echo -n "/etc/sysconfig/$i "
  if [ $? == 0 ]; then
  	echo "OK"
  else
  	echo "FAIL"
  fi
done
