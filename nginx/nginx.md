> OS : Mac OS X

### 负载均衡

*   配置 `nginx.conf`
具体文件在sample/nginx1.conf，复制重写你的`nginx.conf`，或者使用
`nginx -c 下载的文件位置`。关键修改位置：


    设置负载均衡策略
    upstream order {
        server 127.0.0.1:3003 ;
        server 127.0.0.1:3004 ;
        server 127.0.0.1:3005 ;
    }

    server {
        listen       8080;
        #目标host限制
        server_name  order.mock-taobao.com;

        #charset koi8-r;

        # access_log  logs/host.access.log;
        # rewrite "hel{2,}o" /;

        location / {
            #设置反向代理
            proxy_pass http://order;
        }


*  模拟目标host

在`host`文件（Mac下在`/private/etc/hosts`）添加

    #模拟目标host
    127.0.0.1 order.mock-taobao.com


* 启动服务器

下载`sample/order.rb`，打开3个命令行窗口，分别执行：


     export PORT=3003 ; ruby order.rb

     export PORT=3004 ; ruby order.rb

     export PORT=3005 ; ruby order.rb

* 验证

浏览器打开`http://order.mock-taobao.com:8080/hello` ,并多次刷新页面，发现下面依次执行：


    {:port=>"3003", :test=>"{0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5 ...
    {:port=>"3004", :test=>"{0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5 ...
    {:port=>"3005", :test=>"{0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5 ...

并在浏览器开发者工具下可以看到`Transfer-Encoding:chunked`,说明是已经压缩传输。
