#!/bin/sh
# chkconfig: 345 90 10
# description: JBoss EAP 5 Service
#
# JBoss Control Script
# To use this script run it as root - it will switch to the specified user
#
# Either modify this script for your requirements or just ensure that
# the following variables are set correctly before calling the script.

DEFAULT_VARS=/etc/default/jboss-pje
if [[ -f $DEFAULT_VARS ]]; then
    . $DEFAULT_VARS
else
    echo "DEFAULT_VARS '$DEFAULT_VARS' file not found.  Please create it with params for proper JBoss startup."    
    exit 3 # http://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/iniscrptact.html
fi

JBOSS_PROFILE=$JBOSS_1GRAU_PROFILE
JBOSS_BINDING_PORTS=$JBOSS_1GRAU_PORTS
JBOSS_BINDING_IPADDR=$JBOSS_1GRAU_IPADDR

if [ "$JBOSS_BINDING_PORTS" = "ports-default" ]; then 
    JNP_PORT="1099"
elif [ "$JBOSS_BINDING_PORTS" = "ports-01" ]; then 
    JNP_PORT="1199"
elif [ "$JBOSS_BINDING_PORTS" = "ports-02" ]; then 
    JNP_PORT="1299"
elif [ "$JBOSS_BINDING_PORTS" = "ports-03" ]; then 
    JNP_PORT="1399"
elif [ "$JBOSS_BINDING_PORTS" = "ports-04" ]; then 
    JNP_PORT="1499"
else
    echo "JBOSS_BINDING_PORTS is not properly configured (allowed values: 'ports-0[1-4]' or 'ports-default')"
    exit 3  
fi
JBOSS_JNP_PORT="$JNP_PORT"
JBOSS_LOG_LEVEL=${JBOSS_LOG_LEVEL:-"ERROR"}


# make sure java is in your path
JAVABIN=$(which java 2>/dev/null)
if [[ "$JAVABIN" = "" ]]; then
    if [[ ( -n "$JAVA_HOME") && (-x "$JAVA_HOME/bin/java") ]]; then
        JAVABIN="$JAVA_HOME/bin/java"
    else
        echo "Executable 'java' could not be found. It is not in the PATH or JAVA_HOME is not properly set."
        exit 3
    fi
fi

if [ ! -d "$JBOSS_HOME" ]; then
    echo "JBOSS_HOME does not exist as a valid directory: $JBOSS_HOME"
    exit 1
fi

JBOSS_LOG_DIR=${JBOSS_LOG_DIR:-"$JBOSS_HOME/server/$JBOSS_PROFILE/log"}
JBOSS_USER=${JBOSS_USER:-"jboss"}
CLEAR_WORK_TMP=${CLEAR_WORK_TMP:-"Y"}

# Clustering Configs
# Fill these only when using profiling supporting clustering. Otherise they'll be ignored by the script
#    -g, --partition=<name>        HA Partition name (default=DefaultDomain)
#    -m, --mcast_port=<ip>         UDP multicast port; only used by JGroups
#    -u, --udp=<ip>                UDP multicast address
#    -Djboss.default.jgroups.stack=udp|udp-async|udp-sync|tcp|tcp-sync
CLUSTER_PARTITION=${CLUSTER_PARTITION:-"DefaultPartition"}
CLUSTER_JGROUPS_STACK=${CLUSTER_JGROUPS_STACK:-"udp"}
CLUSTER_UDP_MCAST_ADDR=${CLUSTER_UDP_MCAST_ADDR:-"228.11.11.11"}
CLUSTER_UDP_MCAST_PORT=${CLUSTER_UDP_MCAST_PORT:-"55225"}

# JMX Credentials
JMX_USERS_PROPERTIES_FILE="$JBOSS_HOME/server/$JBOSS_PROFILE/conf/props/jmx-console-users.properties"
JMX_CREDENTIALS=$(grep -Eo '^[[:alnum:]]+=[[:print:]]+' $JMX_USERS_PROPERTIES_FILE)
JMX_USER=$(cut -d= -f1 <<<$JMX_CREDENTIALS)
JMX_PASS=$(cut -d= -f2 <<<$JMX_CREDENTIALS)
JBOSS_ADMIN_USER=${JMX_USER:-"admin"}
JBOSS_ADMIN_PASS=${JMX_PASS:-"admin"}

# define the script to use to start jboss
# test if the profile has cluster support
if [ -e $JBOSS_HOME/server/$JBOSS_PROFILE/deploy/cluster ]; then
    RUNSH="$JBOSS_HOME/bin/run.sh -c $JBOSS_PROFILE -b $JBOSS_BINDING_IPADDR -g $CLUSTER_PARTITION -Djboss.default.jgroups.stack=$CLUSTER_JGROUPS_STACK"
    if [[ "$CLUSTER_JGROUPS_STACK" =~ udp* ]]; then
        RUNSH="$RUNSH -u $CLUSTER_UDP_MCAST_ADDR -m $CLUSTER_UDP_MCAST_PORT"
    fi
else
    RUNSH="$JBOSS_HOME/bin/run.sh -c $JBOSS_PROFILE -b $JBOSS_BINDING_IPADDR"
fi

# get the current user
CURRENT_USER=`whoami`

if [ "$JBOSS_USER" = "RUNASIS" -o "$JBOSS_USER" = "$CURRENT_USER"  ]; then
    JBOSS_USER=$CURRENT_USER
    SU_USER=""
else
    SU_USER="su -l $JBOSS_USER -c "
fi

# define what will be done with the console log
JBOSS_CONSOLE=${JBOSS_CONSOLE:-"/dev/null"}
if [[ -e $JBOSS_CONSOLE ]]; then
    if [[ (! -w $JBOSS_CONSOLE) && (! -c $JBOSS_CONSOLE) ]]; then
        chown $JBOSS_USER $JBOSS_CONSOLE
        chmod u+w $JBOSS_CONSOLE
    else
        chmod o+w $JBOSS_CONSOLE
    fi
fi

JBOSS_JVM_PROPS="-Djboss.service.binding.set=$JBOSS_BINDING_PORTS \
    -Djboss.server.log.threshold=$JBOSS_LOG_LEVEL \
    -Djboss.server.log.dir=$JBOSS_LOG_DIR"
JBOSS_CMD_START="$RUNSH $JBOSS_JVM_PROPS"

JBOSSCP=${JBOSSCP:-"$JBOSS_HOME/bin/shutdown.jar:$JBOSS_HOME/client/jnet.jar"} # used for shutdown
JBOSS_CMD_STOP="$JAVABIN -classpath $JBOSSCP org.jboss.Shutdown --shutdown \
    -s jnp://$JBOSS_BINDING_IPADDR:$JBOSS_JNP_PORT \
    -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PASS"

twiddleInfo()
{
    # use twiddle to get some server status 
    TWIDDLE_CMD="$JBOSS_HOME/bin/twiddle.sh -s jnp://$JBOSS_BINDING_IPADDR:$JBOSS_JNP_PORT -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PASS"
    TWIDDLE_CMD_GET="$TWIDDLE_CMD get"
    TWIDDLE_CMD_QRY="$TWIDDLE_CMD query"
    TWIDDLE_CMD_IVK="$TWIDDLE_CMD invoke"

    SERVER_MBEAN="jboss.system:type=Server"
    SERVER_INFO_MBEAN="jboss.system:type=ServerInfo"
    JBOSS_WEB_THREADPOOL_MBEAN="jboss.web:type=ThreadPool,name=http-0.0.0.0-8009"
    JBOSS_WEB_GLOBAL_REQUEST_PROCESSOR_MBEAN="jboss.web:type=GlobalRequestProcessor,name=http-0.0.0.0-8009"
    JBOSS_WEB_DEPLOYMENTS_MBEAN="jboss.web.deployment:*"
    JBOSS_JCA_MBEAN="jboss.jca:*"
    WEB_APP_MBEAN="jboss.web:type=Manager,path="

    #Server Info
    echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN VersionName)"
    echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN VersionNumber)"
    echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN StartDate)"
    echo "      |--- $($TWIDDLE_CMD_GET $SERVER_INFO_MBEAN JavaVersion)"
    echo "          JVM Flags"

    if [ -e "$JAVA_HOME/bin/jinfo" ]; then
        $JAVA_HOME/bin/jinfo -flags $PID 2>&1 | grep "run.sh" | tr ' ' '\n'
    fi

    echo " "
    echo "      |--- $($TWIDDLE_CMD_GET $SERVER_INFO_MBEAN ActiveThreadCount)"

    MaxMemInBytes=`$TWIDDLE_CMD_GET $SERVER_INFO_MBEAN MaxMemory | cut -d '=' -f 2`
    MaxMemInMB=`echo "($MaxMemInBytes/1024/1024)" | bc`
    echo "      |--- MaxMemory = $MaxMemInMB MB"

    FreeMemInBytes=`$TWIDDLE_CMD_GET $SERVER_INFO_MBEAN FreeMemory | cut -d '=' -f 2`
    FreeMemInMB=`echo "($FreeMemInBytes/1024/1024)" | bc`
    echo "      |--- FreeMemory = $FreeMemInMB MB"

    #HTTP ThreadPool
    echo " "
    echo "   JBossWEB "
    echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN maxThreads)" | egrep -v "ERROR|at |Exception"
    echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN currentThreadCount)" | egrep -v "ERROR|at |Exception"
    echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN currentThreadsBusy)" | egrep -v "ERROR|at |Exception"

    #HTTP GlobalRequestProcessor
    echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_GLOBAL_REQUEST_PROCESSOR_MBEAN requestCount)" | egrep -v "ERROR|at |Exception"

    #WebApps 
    echo "      |--- Webapps "

    for WEB_APP in `$TWIDDLE_CMD_QRY $JBOSS_WEB_DEPLOYMENTS_MBEAN | cut -d '=' -f 2 | grep -v 'ROOT'`; do
        echo "      |------ $WEB_APP"
        echo "      |---------> $($TWIDDLE_CMD_GET "${WEB_APP_MBEAN}${WEB_APP},host=localhost" activeSessions)" | egrep -v "ERROR|at |Exception"
    done

    echo " "

    #DataSources
    echo "   Data Sources "

    for DS in `$TWIDDLE_CMD_QRY $JBOSS_JCA_MBEAN | grep ManagedConnectionPool`; do
        echo "      |--- `echo $DS | cut -d ',' -f 2`"
        echo "      |---------> $($TWIDDLE_CMD_GET $DS MaxSize)" | egrep -v "ERROR|at |Exception"
        echo "      |---------> $($TWIDDLE_CMD_GET $DS AvailableConnectionCount)" | egrep -v "ERROR|at |Exception"
        echo "      |---------> $($TWIDDLE_CMD_GET $DS InUseConnectionCount)" | egrep -v "ERROR|at |Exception"
        echo "      |---------> Test Connection: $($TWIDDLE_CMD_IVK $DS testConnection)" | egrep -v "ERROR|at |Exception"
    done
}

cleanWorkTmp()
{
    # clean tmp and work dirs
    rm -Rf "$JBOSS_HOME/server/${JBOSS_PROFILE}/work"
    rm -Rf "$JBOSS_HOME/server/${JBOSS_PROFILE}/tmp"
}

jbossPID()
{
    jbossPID=$(pgrep -f "org\.jboss\.Main -c $JBOSS_PROFILE -b $JBOSS_BINDING_IPADDR -Djboss.service.binding.set=$JBOSS_SERVICE_BIND")
    echo "$jbossPID"
}

start_profile()
{
    # verifica se a instancia jah estah em execucao
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]; then
        echo "starting JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR)..."
        echo "   using service bind: $JBOSS_BINDING_PORTS"

        #echo "JBOSS_CMD_START=$JBOSS_CMD_START"

        if [ -z "$SU_USER" ]; then
            eval $JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &
        else
            $SU_USER "$JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &" 
        fi
    else
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) is already running [PID $PID]"
    fi
}

stop_profile()
{
    echo "stop JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR)..."

    if [ -z "$SU_USER" ]; then
        $JBOSS_CMD_STOP
    else
        #echo "CMD: $JBOSS_CMD_STOP"
        $SU_USER "$JBOSS_CMD_STOP"
    fi 

    sleep 10

    if [ "$CLEAR_WORK_TMP" = "Y" ]; then
        cleanWorkTmp
    fi
}

case "$1" in
start)
    start_profile
    ;;
    
stop)
    stop_profile
    ;;
    
restart)
    stop_profile
    start_profile
    ;;
    
status)
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]; then
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) not running! JVM process not found!"
        exit 3
    else
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) is started [PID $PID]"
        exit 0
    fi  
    ;;  
kill)
    echo "trying halt the JVM process..."

    PID=$(jbossPID)
    if [ "x$PID" = "x" ]; then
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) not running! JVM process not found!"
    else
        echo "process still running..."
        echo "killing JBoss (JVM process) [PID $PID]"
        kill -9 $PID
    fi

    if [ "$CLEAR_WORK_TMP" = "Y" ]; then
        cleanWorkTmp
    fi
    ;;

info)
    clear

    PID=$(jbossPID)
    if [ "x$PID" = "x" ]; then
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) not running! JVM process not found!"
    else
        echo " "
        echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BINDING_IPADDR) running!"
        echo "   JBoss (JVM process) [PID $PID] is UP"
        echo " "
        echo "   Some server info:"

        twiddleInfo
    fi
    ;;
*)
    echo "Usage: $(basename $0) {start|stop|status|restart|kill|info}"
esac
