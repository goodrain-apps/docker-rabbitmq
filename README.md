# Dockerfile for RabbitMQ 

> 这个dockerfile fork自 docker hub的 [官方仓库](https://github.com/docker-library/rabbitmq)。为了更好的支持好雨云的一键部署功能，我们对镜像做了一些适配调整，详细的内容参见下面的说明文档。


<a href="http://app.goodrain.com/app/28/" target="_blank"><img src="http://www.goodrain.com/images/deploy/button_120201.png"></img></a>

# 目录
- [部署到好雨云](#部署到好雨云)
  - [一键部署](#一键部署)
  - [默认用户和密码](#默认用户和密码)
  - [环境变量](#环境变量)
  - [数据安全](#数据安全)
  - [更新](#更新)
- [部署到本地](#部署到本地)
  - [拉取镜像](#拉取镜像)
  - [从dockerfile构建镜像](#从dockerfile构建镜像)
  - [本地运行](#本地运行)
- [内存配置](#内存配置)
- [数据持久化](#数据持久化)
- [磁盘限制](#磁盘限制)
- [启动日志](#启动日志)
- [注意事项](#注意事项)

# 部署到好雨云

## 一键部署
通过点击本文最上方的 “安装到好雨云” 按钮会跳转到 好雨应用市场的应用首页中，可以通过一键部署按钮安装

## 默认用户和密码
在应用市场中安装的RabbitMQ如果在向导中不设置用户名和密码，则平台会默认设置一个用户名（`admin`）和生成一个`随机`的密码。详细的连接信息可以在安装后的应用首页中看到。

## 环境变量

| 变量名 | 变量默认值 | 说明 |
|--------|------------|-------|
|RABBITMQ_HOST|127.0.0.1|连接ip|
|RABBITMQ_PORT|4369|连接端口|
|RABBITMQ_DEFAULT_USER|admin|默认用户|
|RABBITMQ_DEFAULT_PASS|`随机`|默认随机密码|
|MEMORY_SIZE|128M|只读，平台设置|

## 数据安全
平台采用高速SSD固态硬盘来存储数据，并且会有自动备份机制将数据存3份，用户不必担心数据的丢失。默认会将`/var/lib/rabbitmq`目录中的内容进行持久化存储

## 更新
当平台的应用版本检测到有更新时，会出现 如下的图标，可以直接点击更新来更新自己的服务。

[更新图标 - 暂缺]()

`注意：` 请认真查看新版本更新日志，随意更新当前正常运行的应用有可能造成不可预知的问题。


# 部署到本地

## 拉取镜像
```bash
docker pull goodrain.io/rabbitmq:latest
```

## 从dockerfile构建镜像
```bash
git clone https://github.com/goodrain-apps/docker-rabbitmq.git
cd docker-rabbitmq
docker build -t rabbitmq
```
## 本地运行
通过使用`RABBITMQ_*` 的形式设置RabbitMQ的参数如:

```bash
docker run -it -e MEMORY_SIZE=large \
-e RABBITMQ_DEFAULT_USER=admin  \
-e RABBITMQ_DEFAULT_PASS=pass123465 \
-v /tmp/ttt/:/var/lib/rabbitmq \
goodrain.io/rabbitmq:3.6.0-1_123001
```

# 内存配置
默认情况下RabbitMQ的`vm_memory_high_watermark` 设置的是 `0.5` 也就是 应用内存的一半

# 数据持久化
需要挂在外部存储来达到数据持久化的目的，默认挂在到镜像的`/var/lib/rabbitmq` 目录

# 磁盘限制
`disk_free_limit` 默认配置的是应用内存的2倍，如应用内存1G，则磁盘存储限制是2G

# 启动日志

```bash
memory type:large

              RabbitMQ 3.6.0. Copyright (C) 2007-2015 Pivotal Software, Inc.
  ##  ##      Licensed under the MPL.  See http://www.rabbitmq.com/
  ##  ##
  ##########  Logs: tty
  ######  ##        tty
  ##########
              Starting broker...
=INFO REPORT==== 30-Dec-2015::15:32:20 ===
Starting RabbitMQ 3.6.0 on Erlang 18.1
Copyright (C) 2007-2015 Pivotal Software, Inc.
Licensed under the MPL.  See http://www.rabbitmq.com/

=INFO REPORT==== 30-Dec-2015::15:32:20 ===
node           : rabbit@7dbf49e36fed
home dir       : /var/lib/rabbitmq
config file(s) : /etc/rabbitmq/rabbitmq.config
cookie hash    : 9J/elaqxELAONsKbMRNN5g==
log            : tty
sasl log       : tty
database dir   : /var/lib/rabbitmq/mnesia/rabbit@7dbf49e36fed

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Memory limit set to 8024MB of 16048MB total.

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Disk free limit set to 2000MB

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Limiting to approx 524188 file handles (471767 sockets)

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
FHC read buffering:  OFF
FHC write buffering: ON

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Database directory at /var/lib/rabbitmq/mnesia/rabbit@7dbf49e36fed is empty. Initialising from scratch...

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
    application: mnesia
    exited: stopped
    type: temporary

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Priority queues enabled, real BQ is rabbit_variable_queue

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Adding vhost '/'

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Creating user 'zulip'

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Setting user tags for user 'zulip' to [administrator]

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Setting permissions for 'zulip' in '/' to '.*', '.*', '.*'

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
msg_store_transient: using rabbit_msg_store_ets_index to provide index

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
msg_store_persistent: using rabbit_msg_store_ets_index to provide index

=WARNING REPORT==== 30-Dec-2015::15:32:21 ===
msg_store_persistent: rebuilding indices from scratch

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
started TCP Listener on [::]:5672
 completed with 0 plugins.

=INFO REPORT==== 30-Dec-2015::15:32:21 ===
Server startup complete; 0 plugins started.
```


# 注意事项

- run.sh 

> 该脚本中写入配置文件的命令需要用tab分割，否则会造成shell报错，如下面的脚本

```bash
        cat > /etc/rabbitmq/rabbitmq.config <<-'EOH'
            [
              {rabbit,
                [
        EOH
```
**注意**
EOF 标记前一定要用tab，不能用4个空格代替tab，这个是cat 和向文件中写入内容的规范可以用cat -A 命令查看或者 vim编辑器中使用 set list 查看

- ssl 支持

> 当前没有做ssl连接的支持，后续需要的时候再调整
