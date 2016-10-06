require 'zk'
require 'sinatra'
require 'json'
require 'httparty'

class Server
  class << self
    def get_all_servers
      # 需要设置watch才会调用
      servers = ZK_CLIENT.children('/order', watch: true).map do |server_node|
        ZK_CLIENT.get("/order/#{server_node}")[0]
      end
      puts "get servers #{servers}"
      servers
    end
  end

  ZK_CLIENT = ZK.new('localhost:2181,localhost:2182,localhost:2183')
  ZK_CLIENT.create('/order', ignore: :node_exists)
  SERVERS = get_all_servers

  def initialize
    Thread.new do
      ZK_CLIENT.register('/order', only: [:child]) do
        SERVERS.replace self.class.get_all_servers
      end
    end.join
    # 当前使用的服务器位次
    @server_no = 0
  end

  #轮训获取服务器
  def get_order_server
    @server_no += 1
    SERVERS[@server_no % SERVERS.length]
  end
end

server = Server.new

# 端口从系统请求中获取
PORT = ENV['PORT']
set :port, PORT

get '/' do
  cur_server = server.get_order_server
  "from #{cur_server} get :  "+ HTTParty.get("http://#{cur_server}/hello").body
end
