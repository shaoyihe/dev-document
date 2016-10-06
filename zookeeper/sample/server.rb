require 'sinatra'
require 'json'
require 'zk'

# 端口从系统请求中获取
PORT = ENV['PORT']
set :port, PORT


# 注册当前应用到服务器
def register_to_zookeeper
  zoo = ZK.new('localhost:2181,localhost:2182,localhost:2183')
  zoo.create('/order', ignore: :node_exists)
  zoo.create('/order/server-', "localhost:#{PORT}", mode: :ephemeral_sequential)
end

register_to_zookeeper


get '/hello' do
  "from port #{PORT}"
end
