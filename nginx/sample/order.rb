require 'sinatra'
require 'json'

# 端口从系统请求中获取
PORT = ENV['PORT']

set :port, PORT

get '/hello' do
  10000.times.inject({port: PORT}) do |m, k|
    m[k] = k
    m
  end.to_s

end
