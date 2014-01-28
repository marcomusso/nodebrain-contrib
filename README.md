nodebrain-contrib
=================

Some files useful to a nodebrain/caboodle installation

## enable_statup_on_boot.sh

NOTE: only RedHat/CentOS is supported. Tested on RHEL 6.4

The setup directory is intended as a addendum to the same directory in a caboodle.

Run (as root) enable_statup_on_boot.sh to:

1. copy nodebrain.service to /etc/init.d/<agent name> for every agent defined in the AGENTS variable for the caboodle defined in the (guess what) CABOODLE variable
2. add the agents with chkconfig (you can later choose the runlevels, defaults: 2345)
3. create the /etc/sysconfig/<agent name> with some variables

If you want to run the agent as normal user you can define:

	DAEMON_ARGS="export DAEMON_ARGS=\"--user=<your agents user>\""

if your agent (or its servants) require some variables (for example ORACLE_HOME) you can set them in EXTRA_VAR (please note the \n to separate the lines):

	EXTRA_VAR="export ORACLE_HOME=/usr/lib/oracle/12.1/client64\nexport LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib"

Please note: the nodebrain.service file has a different line from the original:

	(start)

        daemon $DAEMON_ARGS "cd $CABOODLE;bin/nb -d --pidfile=$CABOODLE/var/run/$SERVICE.pid $CABOODLE/agent/$AGENT > $CABOODLE/log/$AGENT.out 2>&1"

	(stop)

        killproc -p $CABOODLE/var/run/$SERVICE.pid $SERVICE


basically I added $DAEMON_ARGS to pass (for example) the --user argument and redefined the position of the pid file.

nodebrain.sysconfig (from the original distribution) is not needed since it's created by the script.
