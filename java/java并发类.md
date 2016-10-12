### java并发类

##### 栅栏类（`java.util.concurrent.CyclicBarrier`）

* 目标

当N个线程线程都准备（await）时，同时执行

* 例子

 `CyclicBarrierTest`

* 原理

这个实现比较简单，类中维系一个变量N和一个`java.util.concurrent.locks.Condition`,每次`await`时不到
N时，当前线程处于`java.util.concurrent.locks.Condition.awaitNanos`,否则实施`java.util.concurrent.locks.Condition.signalAll`

##### 信号类（`java.util.concurrent.Semaphore`）

* 原理

许可证获取

#####  `java.util.concurrent.CountDownLatch`

##### 线程安全当`ArrayList`(`java.util.concurrent.CopyOnWriteArrayList`)

* 描述

每次修改`ArrayList`时，底层结构加锁且重新copy。查询不加锁。
大量修改会有性能问题（Vector）。