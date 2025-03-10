#!/usr/bin/env ruby
require 'bunny'

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue('task_queue', durable: true)

# Fair dispatch
channel.prefetch(1) # one message to a worker at a time

puts ' [*] Waiting for messages. To exit press CTRL+C'

begin
  queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
    puts " [x] Received #{body}"
    # imitate some work
    sleep body.count('.').to_i
    puts ' [x] Done'
    # message acknowledgments
    channel.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  connection.close

  exit(0)
end