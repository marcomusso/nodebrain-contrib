#!/bin/sh
#
# 1. copy nodebrain.service to /etc/init.d/ for every caboodle/agent specified
# 2. add the agents with chkconfig (you can later choose the runlevels, defaults: 2345)
# 3. create the /etc/sysconfig/ with some variables

usage() {
  echo "Usage: $0 -c <caboodle full path> -a \"<agent1> <agent2> <...>\" [-u <user>]"
  echo "      if there are multiple agents quote them..."
  exit 1
}

# process command line options
while getopts "hv?a:b:c:u:" opt; do
    case $opt in
        a )      AGENTS=$OPTARG;      ;;
        c )      CABOODLE=$OPTARG;    ;;
        u )      RUNAS=$OPTARG;       ;;
        h | \? ) usage;               ;;
    esac
done
shift $(($OPTIND - 1))

# no mandatory parameters? bail out
[ "x$CABOODLE" = "x" -o "x$AGENTS" = "x" ] && usage
# let's fallback to root if RUNAS is empty
[ "x$RUNAS" = "x" ] && RUNAS=root
# additional variables needed by the agents, ie ORACLE_HOME/LD_LIBRARY_PATH/...
EXTRA_VAR="export ORACLE_HOME=/usr/lib/oracle/12.1/client64\nexport LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib"
# arguments for the daemon function, for example to run nb as another user
DAEMON_ARGS="export DAEMON_ARGS=\"--user=$RUNAS\""

[[ "x$USER" != "xroot" ]] && { echo "This script should be run as root."; exit 1; }
[[ ! -d "$CABOODLE/setup" ]] && { echo "The $CABOODLE/setup directory doesn't exists."; exit 1; }
[[ ! -d "$CABOODLE/var/run" ]] && { echo "The $CABOODLE/var/run directory doesn't exists.\nCreate the directory with the correct user/permissions"; exit 1; }

echo "Enabling startup on boot for agents $AGENTS of caboodle $CABOODLE (as user $RUNAS)."

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
