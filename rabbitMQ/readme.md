> OS: MAC OS X

#### 说明

* 持久化（persistent）
* ACK/Requeing
* AMQP


### 单机

* 安装

`rabbitmq` : `brew install rabbitmq `

* 部署

 启动`rabbitmq-server`。初次需要执行`rabbitmq-plugins enable rabbitmq_management`,启动
 管理插件。打开`http://localhost:15672/`可以看到控制台。

* 例子

执行 `gem install bunny; gem install concurrent;` 安装ruby包. 然后下载执行`sample/queue.rb`:
`ruby queue.rb`. 可以看到消息从生产者到消费者.



