require 'bunny'
require 'concurrent'

conn = Bunny.new 'amqp://guest:guest@localhost:5672'
conn.start

pool = Concurrent::FixedThreadPool.new(10)

#生产者
5.times do |t|
  pool.post do
    ch = conn.create_channel
    test_queue = ch.queue('test-queue', durable: true)
    time = 0
    while true
      # persistent 消息持久化,重启消息仍存在
      test_queue.publish("Hello, from thread #{t} with message #{time = time.succ}!", {persistent: true})
      sleep rand * 10
    end
  end
end


#消费者
5.times do |t|
  pool.post do
    ch = conn.create_channel
    ch.prefetch(1)
    test_queue = ch.queue('test-queue', durable: true)

    test_queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
      puts " [x] Received #{body}"

      # ACK确认才计入完成
      ch.ack(delivery_info.delivery_tag)
      sleep rand * 10
    end
  end
end

pool.wait_for_termination