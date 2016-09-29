> OS : Mac OS X

### redis master/slave

* 目标

    配置
>     master : 127.0.0.1:6385
>     slave  : 127.0.0.1:6386

* 配置

进入一空文件夹，复制`sample/redis-sample1.conf`到此文件夹。执行：

```bash
    echo 's = File.read("redis-sample.conf"); 6385.upto(6386).each{|p| File.write("redis-#{p}.conf", s.gsub("6379",p.to_s))}' |ruby
```
生成2个端口为6385，6385到配置文件：`redis-6385.conf,redis-6386.conf` 。

* 启动

执行：

```bash
    echo '6385.upto(6386).each{|p| system "redis-server redis-#{p}.conf &" }' |ruby
```
分别在2个端口后台启动。
连接端口6386，`redis-cli -p 6386`,执行`slaveof 127.0.0.1 6385`。此时已经配置成功。
可在`6385`端口set 数据再在`6386`验证。

* 客户端连接

客户端可以吧master作为写节点，slave作为读节点。例见[redis_master_slave](https://github.com/oggy/redis_master_slave)。
这种情形如果master挂掉，整个应用为只读。



### redis3.0+官方集群

* 目标

3.0+redis官方提供了分片和集群，至少需要3个master作为分片写节点，3个slave节点作为分片备份读节点。
最终如：

```text
  master 127.0.0.1:6379 slots:0-5460
  slave  127.0.0.1:6382
  master 127.0.0.1:6380 slots:5461-10922
  slave  127.0.0.1:6383
  master 127.0.0.1:6382 slots:10923-16383
  slave  127.0.0.1:6384
```

* 配置

进入一空文件夹，复制`sample/redis-sample2.conf`到此文件夹。执行：

```bash
    echo 's = File.read("redis-sample2.conf"); 6379.upto(6384).each{|p| File.write("redis-#{p}.conf", s.gsub("6379",p.to_s))}' |ruby
```
生成端口6379-6384 6个端口对应读文件。
下载集群依赖文件 `wget http://download.redis.io/redis-stable/src/redis-trib.rb`。

* 启动

执行：
```bash
    echo '6379.upto(6384).each{|p| system "redis-server redis-#{p}.conf &" }' |ruby
```
启动6个redis实例。
启动集群配置：
```bash
    ruby redis-trib.rb create --replicas 1 127.0.0.1:6379 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6382 127.0.0.1:6383 127.0.0.1:6384
```

* 验证

执行`ruby redis-trib.rb check 127.0.0.1:6379`,可以看到：

```text
    >>> Performing Cluster Check (using node 127.0.0.1:6379)
    M: fbe3aa12481491eb46cda23584a84e6c8c0bac01 127.0.0.1:6379
       slots:0-5460 (5461 slots) master
       1 additional replica(s)
    M: 53f110cf2c525f24984be1ae3aa95e76161be20f 127.0.0.1:6381
       slots:10923-16383 (5461 slots) master
       1 additional replica(s)
    S: 3c8171c08f065ef3f2e4d4b02ceada18eb509804 127.0.0.1:6384
       slots: (0 slots) slave
       replicates 53f110cf2c525f24984be1ae3aa95e76161be20f
    S: 3e94e63ea7ee9192520b734d5c5b1b98e7ea2f4d 127.0.0.1:6382
       slots: (0 slots) slave
       replicates fbe3aa12481491eb46cda23584a84e6c8c0bac01
    M: 0c9ff45e7a026362a0593ac23a929284f574c929 127.0.0.1:6380
       slots:5461-10922 (5462 slots) master
       1 additional replica(s)
    S: 3f73aaf23e0a071251bd58e83ce223e58880b03b 127.0.0.1:6383
       slots: (0 slots) slave
       replicates 0c9ff45e7a026362a0593ac23a929284f574c929
    [OK] All nodes agree about slots configuration.
    >>> Check for open slots...
    >>> Check slots coverage...
    [OK] All 16384 slots covered.
```
也可以连接6379集群端口`redis-cli -c -p 6379`，执行：

```text
127.0.0.1:6379> set 2 2
-> Redirected to slot [5649] located at 127.0.0.1:6380  # 分片到6380
OK
127.0.0.1:6380> get 2
"2"
127.0.0.1:6380> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:2
cluster_stats_messages_sent:54760
cluster_stats_messages_received:54760
```