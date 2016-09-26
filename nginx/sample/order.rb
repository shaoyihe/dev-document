require 'sinatra'
require 'json'

# 端口从系统请求中获取
PORT = ENV['PORT']

set :port, PORT

get '/hello' do
  for_test = 10000.times.inject({}) do |m, k|
    m[k] = k
    m
  end.to_s

  {port: PORT, test: for_test}.to_s
end
