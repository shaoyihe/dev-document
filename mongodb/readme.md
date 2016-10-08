> OS : Mac OS X

* 安装

`brew install mongodb`

### 单机

* 启动

进入一空文件夹，执行（dbpath：设置当前目录为数据目录）：
```
    mongod --dbpath `pwd`
```

* 验证
```
○ → mongo
MongoDB shell version: 3.2.7
connecting to: test
> db.isMaster()
{
	"ismaster" : true,
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 1000,
	"localTime" : ISODate("2016-10-08T12:11:41.460Z"),
	"maxWireVersion" : 4,
	"minWireVersion" : 0,
	"ok" : 1
}
> rs.status()
{ "ok" : 0, "errmsg" : "not running with --replSet", "code" : 76 }
> coll = db.first_coll;
test.first_coll
> coll.insert({name: 'first test'})
WriteResult({ "nInserted" : 1 })
> coll.find()
{ "_id" : ObjectId("57f8e2b20a7af778eaaf2e4e"), "name" : "first test" }
```

### 集群(Replication)

* 目标

启动3个mongo实例，1个为primary，2个secondary。如下：
```
primary: localhost:40000
secondary: localhost:40001
secondary: localhost:40002
```
* 配置

进入一空文件夹，执行：
```bash
    mkdir 40000 40001 40002
	mongod --replSet for-test --dbpath `pwd`/40000 --port 40000 &
	mongod --replSet for-test --dbpath `pwd`/40001 --port 40001 &
	mongod --replSet for-test --dbpath `pwd`/40002 --port 40002 &
```

然后加入集群：
```
○ → mongo localhost:40000
MongoDB shell version: 3.2.7
connecting to: localhost:40000/test
> config = {
...     _id : "for-test",
...      members : [
...          {_id : 0, host : "localhost:40000"},
...          {_id : 1, host : "localhost:40001"},
...          {_id : 2, host : "localhost:40002"},
...      ]
... }
{
	"_id" : "for-test",
	"members" : [
		{
			"_id" : 0,
			"host" : "localhost:40000"
		},
		{
			"_id" : 1,
			"host" : "localhost:40001"
		},
		{
			"_id" : 2,
			"host" : "localhost:40002"
		}
	]
}
> rs.initiate(config)
{ "ok" : 1 }
for-test:SECONDARY> rs.status()
{
	"set" : "for-test",
	"date" : ISODate("2016-10-08T12:34:03.520Z"),
	"myState" : 1,
	"term" : NumberLong(1),
	"heartbeatIntervalMillis" : NumberLong(2000),
	"members" : [
		{
			"_id" : 0,
			"name" : "localhost:40000",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 278,
			"optime" : {
				"ts" : Timestamp(1475930040, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2016-10-08T12:34:00Z"),
			"infoMessage" : "could not find member to sync from",
			"electionTime" : Timestamp(1475930039, 1),
			"electionDate" : ISODate("2016-10-08T12:33:59Z"),
			"configVersion" : 1,
			"self" : true
		},
		{
			"_id" : 1,
			"name" : "localhost:40001",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 15,
			"optime" : {
				"ts" : Timestamp(1475930028, 1),
				"t" : NumberLong(-1)
			},
			"optimeDate" : ISODate("2016-10-08T12:33:48Z"),
			"lastHeartbeat" : ISODate("2016-10-08T12:34:01.862Z"),
			"lastHeartbeatRecv" : ISODate("2016-10-08T12:34:02.170Z"),
			"pingMs" : NumberLong(0),
			"configVersion" : 1
		},
		{
			"_id" : 2,
			"name" : "localhost:40002",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 15,
			"optime" : {
				"ts" : Timestamp(1475930028, 1),
				"t" : NumberLong(-1)
			},
			"optimeDate" : ISODate("2016-10-08T12:33:48Z"),
			"lastHeartbeat" : ISODate("2016-10-08T12:34:01.851Z"),
			"lastHeartbeatRecv" : ISODate("2016-10-08T12:34:02.177Z"),
			"pingMs" : NumberLong(0),
			"configVersion" : 1
		}
	],
	"ok" : 1
}
```

* 验证

```bash
# PRIMARY
○ → mongo localhost:40000
MongoDB shell version: 3.2.7
connecting to: localhost:40000/test
for-test:PRIMARY> q db.questions
2016-10-08T20:36:44.539+0800 E QUERY    [thread1] SyntaxError: missing ; before statement @(shell):1:2

for-test:PRIMARY> q = db.questions
test.questions
for-test:PRIMARY> q.insert({title: 'how to config mongo'})
WriteResult({ "nInserted" : 1 })
for-test:PRIMARY> q.find()
{ "_id" : ObjectId("57f8e874b6d8f59b9a5d8988"), "title" : "how to config mongo" }

# SECONDARY
○ → mongo localhost:40001
MongoDB shell version: 3.2.7
connecting to: localhost:40001/test
for-test:SECONDARY> rs.slaveOk()
for-test:SECONDARY> q= db.questions
test.questions
for-test:SECONDARY> q.find()
{ "_id" : ObjectId("57f8e874b6d8f59b9a5d8988"), "title" : "how to config mongo" }
```
