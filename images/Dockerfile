FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos-jdk:7.7.1908

RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
RUN yum install -y clickhouse-server clickhouse-client

# copy config
COPY  metrika.xml /etc/

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh

# 授权
RUN chown -R clickhouse:clickhouse /var/lib/clickhouse/  /etc/clickhouse-server/ /var/log/clickhouse-server
RUN chown -R clickhouse:clickhouse /opt/apache

WORKDIR /opt/apache
