### 性能优化方法

* 查询缓存（Query Cache）

   在SQL中使用绑定变量来替换变量（例如：`CURDATE`）
   @see [Speed Up Your Web Site With MySQL Query Caching](http://www.howtogeek.com/howto/programming/speed-up-your-web-site-with-mysql-query-caching/)

* 为搜索字段建索引
* 避免 SELECT *
* 拆分大的 DELETE 或 INSERT 语句


refer:
   1. [MySQL性能优化的最佳20+条经验](http://coolshell.cn/articles/1846.html)