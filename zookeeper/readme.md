> OS : MAC OS X

### 集群配置

* 安装

 `brew install zookeeper`

* 配置

 进入一空文件夹，复制`sample/zoo.sample.conf`到此文件夹。执行：
 ```bash
     echo 's = File.read("zoo.sample.conf"); 2181.upto(2183).each{|p| File.write("zoo_#{p}.conf", s.gsub("2181",p.to_s).gsub("pwd","#{`pwd`[0..-2]}"))}' |ruby
 ```

 生成3个连接端口为2181，2182, 2383到配置文件：`zoo_2181.conf  zoo_2182.conf  zoo_2183.conf` 。

* 启动
```bash
 echo '2181.upto(2183).each{|p| system "mkdir data_#{p}; echo #{p - 2180} > data_#{p}/myid ; zkServer start `pwd`/zoo_#{p}.conf" }' |ruby
```
生成3个数据目录,并在中写入节点ID到myid文件,然后启动3个实例(2181，2182, 2383).

* 验证

可以打开3个zookeeper不同端口客户端: `zkCli -server localhost:2181` :

```test
[zk: localhost:2181(CONNECTED) 2] create /test-zoo test
Created /test-zoo
```
然后在端口2182的实例中看到同步结果:

```test
[zk: localhost:2182(CONNECTED) 1] get /test-zoo
test
cZxid = 0x100000007
ctime = Thu Oct 06 19:41:48 CST 2016
mZxid = 0x100000007
mtime = Thu Oct 06 19:41:48 CST 2016
pZxid = 0x100000007
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0
```

### 服务注册/发现

* 目标

启动3个服务器应用,将自己注册到zookeeper节点`/order`的子节点(ephemeral_sequential),客户端监控(watch)该
节点,如果子节点添加或者移除,则拉取服务器注册信息. 最终客户端轮训HTTP调用服务器应用.
```
   #服务器节点
   localhost:8080
   localhost:8081
   localhost:8082
   # 客户端节点
   localhost:8083
```

* 启动

安装gem包.`gem install sinatra; gem install json; gem install zk; gem install httparty;`
下载`sample/client.rb和sample/server.rb`.文件

先启动客户端`export PORT=8083; ruby client.rb`.再启动3个服务器端

```
export PORT=8080; ruby server.rb
export PORT=8081; ruby server.rb
export PORT=8082; ruby server.rb
```
最终在客户端输出:

```text
○ → export PORT=8083; ruby client.rb
get servers []
== Sinatra/1.4.4 has taken the stage on 8083 for development with backup from Thin
>> Thin web server (v1.5.1 codename Straight Razor)
>> Maximum connections set to 1024
>> Listening on localhost:8083, CTRL+C to stop
get servers ["localhost:8080"]
get servers ["localhost:8081", "localhost:8080"]
get servers ["localhost:8082", "localhost:8081", "localhost:8080"]
```
然后浏览器打开客户端连接`http://localhost:8083/`,刷新多次,会看到来自不同应用的信息.
```
#轮训下面3条
from localhost:8081 get : from port 8081
from localhost:8082 get : from port 8082
from localhost:8080 get : from port 8080
```
回到`zkCli`客户端,可以看到:
```
[zk: localhost:2181(CONNECTED) 1] ls /
[zookeeper, test, test-zoo, order]
[zk: localhost:2181(CONNECTED) 2] ls /order
[server-0000000002, server-0000000001, server-0000000000]
[zk: localhost:2181(CONNECTED) 3] get /order/server-0000000002
localhost:8082
cZxid = 0x10000001f
ctime = Thu Oct 06 19:53:42 CST 2016
mZxid = 0x10000001f
mtime = Thu Oct 06 19:53:42 CST 2016
pZxid = 0x10000001f
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x25799c7e9630005
dataLength = 14
numChildren = 0
```
然后依次停掉3个服务器应用,看到客户端输出:
```
get servers ["localhost:8081", "localhost:8080"]
get servers ["localhost:8080"]
get servers []
```
`zkCli`那里已经为空节点了:
```
[zk: localhost:2181(CONNECTED) 4] ls /order
[]
```