require 'rbczmq'

def query(context, address, port)

  dealer = context.socket(:DEALER)
  server = "tcp://192.168.1.#{address}:#{port}"
  puts "Query hello server at: #{server}"

  dealer.rcvtimeo = 5_000
  dealer.sndtimeo = 5_000
  dealer.connect(server)

  message = "Hello"
  puts "#{server} < #{message.inspect}"
  dealer.send(message)

  msg = dealer.recv
  puts "#{server} > '#{msg}'"
  dealer.close

end

context = ZMQ::Context.new
socket  = context.socket(:SUB)
socket.rcvhwm = 20
socket.rcvtimeo = 5_000
socket.subscribe ""

pattern = /^(\d{1,3}):(\d{1,5})$/

for ip in [9, 25]
  address = "tcp://192.168.1.#{ip}:6665"
  rc = socket.connect(address)
end

while true
  msg = socket.recv

  if msg.to_i != -1 && msg.to_s.size > 0
    result = pattern.match(msg.to_s)
    puts "Service discovered: #{msg.inspect}"
    query(context, result[1], result[2]) if result
  else
    puts "Error msg: #{msg.inspect}"
  end

end
