# Dockerized RabbitMQ 3.6-1

## 使用

### 变量配置
通过使用`RABBITMQ_*` 的形式设置RabbitMQ的参数如:

```bash
docker run -it -e MEMORY_SIZE=large \
-e RABBITMQ_DEFAULT_USER=zulip  \
-e RABBITMQ_DEFAULT_PASS=zulip \
-v /tmp/ttt/:/var/lib/rabbitmq \
goodrain.me/rabbitmq:3.6.0-1_123001
```

### 内存配置
默认情况下RabbitMQ的`vm_memory_high_watermark` 设置的是 `0.5` 也就是 应用内存的一半

### 数据持久化
需要挂在外部存储来达到数据持久化的目的，默认挂在到镜像的`/var/lib/rabbitmq` 目录

### 磁盘限制
`disk_free_limit` 默认配置的是应用内存的2倍，如应用内存1G，则磁盘存储限制是2G

### 启动日志

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


## 注意

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
