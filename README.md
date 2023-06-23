@[TOC]
## 一、概述
 > ClickHouse是一种**高性能、列式存储的分布式数据库管理系统**。它专注于快速数据分析和查询，并且在大规模数据集上表现出色。

在ClickHouse中，数据按列存储而不是按行存储。这种存储方式有许多优点，特别适合分析工作负载。下面是一些与列数据存储相关的关键概念和特点：

- **列存储**：ClickHouse将每一列的数据连续存储在磁盘上，这种存储方式有助于高效地进行压缩和编码。相比之下，传统的行存储数据库会将整行数据存储在一起。

- **列压缩**：ClickHouse使用多种压缩算法来减小列数据的存储空间。这些算法针对不同类型的数据（例如数字、字符串、日期等）进行了优化，可以显著减少存储成本。

- **列编码**：ClickHouse还使用列编码来提高查询性能。列编码是一种将相似值存储在一起的技术，可以减少磁盘读取和解压缩的数据量。

- **数据分区**：ClickHouse支持数据分区，可以将数据划分为更小的部分，以便更高效地执行查询。数据分区可以根据时间、日期、范围或自定义规则进行。

- **合并树（MergeTree）引擎**：ClickHouse的默认存储引擎是MergeTree，它是基于列存储和数据分区的。MergeTree引擎支持高效的数据插入和查询，并且具有自动合并和数据删除的功能。

总的来说，ClickHouse的列数据存储方式以及相关的压缩和编码技术使其在大规模数据分析场景下表现出色。它能够高效地处理海量数据，并提供快速的查询性能。

![在这里插入图片描述](https://img-blog.csdnimg.cn/ecf196172c3b4f29a101049ce90ce013.png)
这里主要侧重使用docker快速部署环境，想了解更多，可以参考我以下几篇文章：
- [列式数据库管理系统——ClickHouse（version：22.7.1 环境部署）](https://mp.weixin.qq.com/s?__biz=MzI3MDM5NjgwNg==&mid=2247485271&idx=1&sn=7e6223c567e9e5417f8086d821668b0e&chksm=ead0fbbedda772a816de9b42d609df7e16ceaf3abf46566cf19a5c154e5fc52bd6a3c8474784#rd)
- [列式数据库管理系统——ClickHouse实战演练](https://mp.weixin.qq.com/s?__biz=MzI3MDM5NjgwNg==&mid=2247485196&idx=1&sn=a776199e8cf04bfff8e42b6b4af3facf&chksm=ead0fbe5dda772f31a701257f85990ca4030d75097e89adf8e338036c81e1d835ac2425e4f4c#rd)

官方文档：[https://clickhouse.com/docs/zh](https://clickhouse.com/docs/zh)
## 二、ClickHouse 列数据存储优缺点
ClickHouse的列数据存储方式具有许多优点和一些缺点。下面是对ClickHouse列数据存储的主要优缺点的总结：
### 1）优点

- **高压缩率**：列数据存储允许对每一列使用专门的压缩算法，针对不同类型的数据进行优化，从而实现更高的压缩率。这可以显著减小数据存储的需求，降低硬件成本。

- **高查询性能**：列数据存储适用于分析型工作负载，其中查询通常涉及少量列而涵盖大量行。由于每个查询只需要读取所需的列数据，而不是整行数据，所以列数据存储通常比行存储更快。

- **数据压缩对查询性能的提升**：由于列数据存储的数据压缩，它可以减少磁盘I/O操作和网络传输，提高查询性能。较小的数据量意味着更少的磁盘读取和更快的数据传输速度。

- **数据分区和合并**：ClickHouse支持数据分区和合并树引擎，这使得对大规模数据集的查询和分析更加高效。数据分区允许将数据划分为更小的部分，从而减少需要扫描的数据量。自动合并和数据删除功能确保数据的连续性和性能。

### 2）缺点

更新和删除操作相对复杂：由于列数据存储的特性，更新和删除操作可能相对复杂。这是因为更新和删除需要定位并修改多个列的数据，而不仅仅是单个行。

- **不适合高并发的事务处理**：ClickHouse的设计目标是快速数据分析和查询，而不是高并发的事务处理。如果应用程序需要大量的并发事务操作和实时写入需求，ClickHouse可能不是最佳选择。

- **不适合频繁变更的模式**：由于列存储的特性，如果数据模式经常发生变化，例如添加或删除列，可能需要进行较大的重建操作。因此，ClickHouse更适合稳定的数据模式和预先定义的查询需求。

总的来说，ClickHouse的列数据存储方式在大规模数据分析场景下具有许多优势，包括高压缩率、高查询性能和灵活的数据分区。然而，它可能不适合需要频繁更新和变更模式的应用程序，并且不是专为高并发的事务处理而设计。

## 三、ClickHouse 中 Zookeeper 的作用
在 ClickHouse 中，ZooKeeper 扮演着协调和管理分布式集群的角色。它作为一个分布式协调服务，为 ClickHouse 提供了以下功能和作用：

- **配置管理**：ZooKeeper 用于存储和管理 ClickHouse 集群的配置信息，包括集群拓扑、节点信息、数据分片和副本分配等。ClickHouse 节点通过与 ZooKeeper 进行交互，获取集群的配置信息，从而了解集群的拓扑结构和各个节点的角色。

- **Leader 选举**：在 ClickHouse 集群中，每个分片都有一个 Leader 节点负责协调和处理读写请求。ZooKeeper 用于协助进行 Leader 的选举过程，确保在节点故障或重启后能够快速选举出新的 Leader 节点来维持集群的可用性。

- **监控和健康检查**：ZooKeeper 可以用于监控 ClickHouse 集群的健康状态。ClickHouse 节点可以将自身的状态信息注册到 ZooKeeper 上，同时定期向 ZooKeeper 发送心跳信号。这样可以实现集群的实时监控和故障检测，如果节点出现故障或不可用，可以及时做出相应的处理。

- **分布式锁和协调**：ZooKeeper 提供了分布式锁和协调的功能，可以用于在 ClickHouse 集群中实现一致性操作和并发控制。例如，当进行某些需要串行执行的操作时，可以使用 ZooKeeper 的分布式锁来确保只有一个节点可以执行该操作，从而避免冲突和数据不一致的问题。

总的来说，ZooKeeper 在 ClickHouse 中扮演着关键的角色，用于集群的配置管理、Leader 选举、监控和健康检查以及分布式锁和协调。它提供了分布式环境下的协同工作和一致性保证，帮助确保 ClickHouse 集群的稳定运行和可靠性。
## 四、前期准备
### 1）部署 docker
```bash
# 安装yum-config-manager配置工具
yum -y install yum-utils

# 建议使用阿里云yum源：（推荐）
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装docker-ce版本
yum install -y docker-ce
# 启动并开机启动
systemctl enable --now docker
docker --version
```
### 2）部署 docker-compose
```bash
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version
```
## 五、创建网络

```bash
# 创建，注意不能使用hadoop_network，要不然启动hs2服务的时候会有问题！！！
docker network create hadoop-network

# 查看
docker network ls
```
## 六、安装  Zookeeper
这里选择docker快速部署的方式：[【中间件】通过 docker-compose 快速部署 Zookeeper 保姆级教程](https://blog.csdn.net/qq_35745940/article/details/130774794)

```bash
git clone https://gitee.com/hadoop-bigdata/docker-compose-zookeeper.git

cd docker-compose-zookeeper

# 部署
docker-compose -f docker-compose.yaml up -d

# 查看
docker-compose -f docker-compose.yaml ps
```
## 七、ClickHouse  编排部署
![在这里插入图片描述](https://img-blog.csdnimg.cn/b5f336ce7b564655a12af8af11d4ea19.png)
### 1）下载 ClickHouse 安装包
这里选择使用yum安装方式，也可以选择离线安装包部署，具体教程可参考官方部署文档：[https://clickhouse.com/docs/zh/getting-started/install](https://clickhouse.com/docs/zh/getting-started/install)
### 2）配置
- `config/config.xml`

修改`/etc/clickhouse-server/config.xml`，是本地和远程可登陆，配置文件内容比较多，这里就粘贴出来了。

```xml
<listen_host>0.0.0.0</listen_host>

<clickhouse>
<!-- 默认是没有的，直接新增就行 -->
<include_from>/etc/metrika.xml</include_from>
<!--- 将默认的配置删掉 -->
<remote_servers incl="clickhouse_remote_servers" />
<zookeeper incl="zookeeper" optional="true" />
<macros incl="macros" optional="true" />
<!-- 删掉默认配置 -->
<compression incl="clickhouse_compression" optional="true" />

</clickhouse>

```

- `config/users.xml`

修改 `/etc/clickhouse-server/users.xml`，配置密码，其它参数可以根据业务场景进行配置，在`55`行左右

```xml
<password>123456</password>
```

- `images/metrika.xml`

```xml
<yandex>
    <!--ck集群节点-->
    <clickhouse_remote_servers>
        <!-- 集群名称 -->
        <ck_cluster_2023>
            <!--shard 1(分片1)-->
            <shard>
                <weight>1</weight>
                <!-- internal_replication这个参数是控制写入数据到分布式表时，分布式表会控制这个写入是否的写入到所有副本中，这里设置false，就是只会写入到第一个replica，其它的通过zookeeper同步 -->
                <internal_replication>false</internal_replication>
                <replica>
                    <host>ck-node-1</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
                <!--replicat 1(副本 1)-->
                <replica>
                    <host>ck-node-2</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
            </shard>
            <!--shard 2(分片2)-->
            <shard>
                <weight>1</weight>
                <internal_replication>false</internal_replication>
                <replica>
                    <host>ck-node-3</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
                <!--replicat 2(副本 2)-->
                <replica>
                    <host>ck-node-4</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
            </shard>
        </ck_cluster_2023>
    </clickhouse_remote_servers>
    <!--zookeeper相关配置-->
    <zookeeper>
        <node index="1">
            <host>zookeeper-node1</host>
            <port>2181</port>
        </node>
        <node index="2">
            <host>zookeeper-node2</host>
            <port>2181</port>
        </node>
        <node index="3">
            <host>zookeeper-node3</host>
            <port>2181</port>
        </node>
    </zookeeper>
    <macros>
        <!-- 本节点副本名称，创建复制表时有用，每个节点不同，整个集群唯一，建议使用主机名+副本+分片），在当前节点上-->
        <shard>${macros_shard}</shard>
        <replica>${macros_replica}</replica>
    </macros>
    <!-- 监听网络 -->
    <networks>
        <ip>::/0</ip>
    </networks>
    <!--压缩相关配置-->
    <clickhouse_compression>
        <case>
            <min_part_size>1073741824</min_part_size>
            <min_part_size_ratio>0.01</min_part_size_ratio>
            <method>lz4</method>
            <!--压缩算法lz4压缩比zstd快, 更占磁盘-->
        </case>
    </clickhouse_compression>
</yandex>
```
> 注意上面 `macros` 配置，上面配置的只是一个占位符，服务启动之前会自动替换。
### 3）启动脚本 bootstrap.sh

```bash
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
```
### 4）构建镜像 Dockerfile

```bash
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
# 授权
RUN chown -R clickhouse:clickhouse /var/lib/clickhouse/  /etc/clickhouse-server/ /var/log/clickhouse-server
RUN chown -R clickhouse:clickhouse /opt/apache


WORKDIR /opt/apache
```
开始构建镜像

```bash
docker build -t registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24 . --no-cache --progress=plain

# 为了方便小伙伴下载即可使用，我这里将镜像文件推送到阿里云的镜像仓库
docker push registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24

### 参数解释
# -t：指定镜像名称
# . ：当前目录Dockerfile
# -f：指定Dockerfile路径
#  --no-cache：不缓存

```
### 5）编排 docker-compose.yaml

```yaml
version: '3'
services:
  ck-node-1:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24
    container_name: ck-node-1
    hostname: ck-node-1
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./config/config.xml:/etc/clickhouse-server/config.xml
      - ./config/users.xml:/etc/clickhouse-server/users.xml
    expose:
      - "${CilckHouse_PORT}"
    ports:
      - "${ClickHouse_HTTP_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${CilckHouse_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 5
  ck-node-2:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24
    container_name: ck-node-2
    hostname: ck-node-2
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./config/config.xml:/etc/clickhouse-server/config.xml
      - ./config/users.xml:/etc/clickhouse-server/users.xml
    expose:
      - "${CilckHouse_PORT}"
    ports:
      - "${ClickHouse_HTTP_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${CilckHouse_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 5
  ck-node-3:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24
    container_name: ck-node-3
    hostname: ck-node-3
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./config/config.xml:/etc/clickhouse-server/config.xml
      - ./config/users.xml:/etc/clickhouse-server/users.xml
    expose:
      - "${CilckHouse_PORT}"
    ports:
      - "${ClickHouse_HTTP_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${CilckHouse_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 5
  ck-node-4:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/clickhouse:23.5.3.24
    container_name: ck-node-4
    hostname: ck-node-4
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./config/config.xml:/etc/clickhouse-server/config.xml
      - ./config/users.xml:/etc/clickhouse-server/users.xml
    expose:
      - "${CilckHouse_PORT}"
    ports:
      - "${ClickHouse_HTTP_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${CilckHouse_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 5

# 连接外部网络
networks:
  hadoop-network:
    external: true
```
`.env` 文件内容

```bash
CilckHouse_PORT=9000
ClickHouse_HTTP_PORT=8123
```
### 6）开始部署

```bash
# --project-name指定项目名称，默认是当前目录名称
docker-compose -f docker-compose.yaml up -d

# 查看
docker-compose -f docker-compose.yaml ps

# 卸载
docker-compose -f docker-compose.yaml down
```

### 7）简单测试验证

```bash
# 登录容器
docker exec -it ck-node-1 bash

# 默认情况下，在批量模式中只能执行单个查询。为了从一个Script中执行多个查询，可以使用--multiquery参数。
clickhouse-client -u default --password 123456 --port 9000 -h localhost --multiquery

select * from system.clusters;
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/66b4e3222f5d4347b0e6f19eea958884.png)
### 8）web 访问
`http://ip:port/play`
获取对外port

```bash
docker-compose -f docker-compose.yaml ps
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/be9e9edf7d484a4f8f0da1eadb71f83a.png)
参数说明：

- `cluster`： 集群的命名
- `shard_num`： 分片的编号
- `shard_weight`： 分片的权重
- `replica_num`： 副本的编号
- `host_name`： 机器的host名称
- `host_address`： 机器的ip地址
- `port`： clickhouse集群的端口
- `is_local`： 是否为你当前查询本地
- `user`： 创建用户

---

到此通过 docker-compose 快速部署 ClickHouse 保姆级教程就结束了，有任何疑问请关注我公众号：`大数据与云原生技术分享`，加群交流或私信沟通~

![输入图片说明](https://foruda.gitee.com/images/1687512837462105450/3262dc14_1350539.png "屏幕截图")