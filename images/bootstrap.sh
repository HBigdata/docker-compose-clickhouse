#!/bin/bash

# 修改 macros 配置，
# 格式：${hostname}-${macros}-${replica}
# 示例：local-168-182-110-01-1
last=`hostname| awk -F'-' '{print $NF}'`
if [ $last -eq 1 -o $last -eq 2 ];then
   macros_shard="01"
   macros_replica=`hostname`-${macros_shard}-$last
fi

if [ $last -eq 3 -o $last -eq 4 ];then
   macros_shard="02"
   let last=last-2
   macros_replica=`hostname`-${macros_shard}-$last
fi

# 替换
sed -i "s/\${macros_shard}/${macros_shard}/" /etc/metrika.xml
sed -i "s/\${macros_replica}/${macros_replica}/" /etc/metrika.xml

sudo /etc/init.d/clickhouse-server start

tail -f /var/log/clickhouse-server/clickhouse-server.log
