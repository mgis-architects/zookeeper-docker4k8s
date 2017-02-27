#!/bin/bash

declare -A serverlist

for i in $( eval echo {1..$MAX_SERVERS});do
   serverlist["zookeeper-${i}"]=${i}
done

if [ ! -z "$NAMESPACE" ]; then
   NAMESPACE=".${NAMESPACE}"
fi

echo "$MAX_SERVERS $NAMESPACE"
if [ ! -z "$MAX_SERVERS" ]; then
  echo "Starting up in clustered mode"
  echo "" >> /opt/zookeeper/conf/zoo.cfg
  echo "#Server List" >> /opt/zookeeper/conf/zoo.cfg
  for i in $( eval echo {1..$MAX_SERVERS});do
    if [ "${i}" -eq ${serverlist[$(hostname)]} ];then
      echo "server.$i=0.0.0.0:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    else
      echo "server.$i=zookeeper-${i}${NAMESPACE}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    fi
  done
  cat /opt/zookeeper/conf/zoo.cfg

  # Persists the ID of the current instance of Zookeeper
  echo ${serverlist[$(hostname)]} > /opt/zookeeper/data/myid
  else
          echo "Starting up in standalone mode"
fi

exec /opt/zookeeper/bin/zkServer.sh start-foreground