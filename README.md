nodebrain-contrib
=================

Some files useful to a nodebrain/caboodle installation

## enable_statup_on_boot.sh

NOTE: only RedHat/CentOS is supported. Tested on RHEL 6.4

The setup directory is intended as an addendum to the same directory in a caboodle.

Run (as root) enable_statup_on_boot.sh to:

1. copy nodebrain.service to /etc/init.d/<agent name> for every agent defined in the AGENTS variable for the caboodle defined in the (guess what) CABOODLE variable
2. add the agents with chkconfig (you can later choose the runlevels, defaults: 2345)
3. create the /etc/sysconfig/<agent name> with some variables

## Usage

	enable_statup_on_boot.sh -c <caboodle full path> -a "<agent1> <agent2> <...>" [-u <user>]"

If there are multiple agents quote them...

## Additional customizations

if your agent (or its servants) require some variables (for example ORACLE_HOME) you can set them in EXTRA_VAR (please note the \n to separate the lines):

	EXTRA_VAR="export ORACLE_HOME=/usr/lib/oracle/12.1/client64\nexport LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib"

Please note: the nodebrain.service file has a different line from the original:

	(start: added $DAEMON_ARGS, changed the parameter order for nb)

        daemon $DAEMON_ARGS "cd $CABOODLE;bin/nb -d $CABOODLE/agent/$AGENT --pidfile=$CABOODLE/var/run/$SERVICE.pid > $CABOODLE/log/$AGENT.out 2>&1"

	(stop: tells killproc where is the pidfile)

        killproc -p $CABOODLE/var/run/$SERVICE.pid $SERVICE


$DAEMON_ARGS is used (for example) to pass the --user argument to start an agent as a regular user (passed as -u in the script).

nodebrain.sysconfig (from the original distribution) is not needed since it's created dynamically by the script.

## TODO

It would be nice to be able to use the connect command even if the agent is started without nbkit.
Right now I could use:

	bin/nb ':define agentname node peer("agentname@socket/agentname");' -">agentname:"

Perhaps defined as a function:

	function connect2agent {
	  if [ $# -eq 0 ]; then
	    echo "Please specify agent name."
	  else
	    bin/nb ":define $1 node peer(\"$1@socket/$1\");" -">$1:"
	  fi
	}

