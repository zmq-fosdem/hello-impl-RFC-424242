require 'ffi-rzmq'

def query(context, address, port)

  dealer = context.socket(ZMQ::DEALER)
  server = "tcp://192.168.1.#{address}:#{port}"
  puts "Query hello server at: #{server}"

  dealer.setsockopt(ZMQ::RCVTIMEO, 5_000)
  dealer.setsockopt(ZMQ::SNDTIMEO, 5_000)
  dealer.connect(server)

  message = "Hello"
  puts "#{server} < #{message.inspect}"
  dealer.send_string message

  msg = ""
  dealer.recv_string(msg)
  puts "#{server} > '#{msg}'"
  dealer.close

end

context = ZMQ::Context.new
socket  = context.socket(ZMQ::SUB)
socket.setsockopt(ZMQ::SUBSCRIBE, "")
socket.setsockopt(ZMQ::RCVHWM, 20)
socket.setsockopt(ZMQ::RCVTIMEO, 5_000)

pattern = /^(\d{1,3}):(\d{1,5})$/

for ip in [9, 25]
  address = "tcp://192.168.1.#{ip}:6665"
  rc = socket.connect(address)
end

while true
  msg = ''
  rc = socket.recv_string(msg)

  if msg.to_i != -1 && msg.to_s.size > 0
    result = pattern.match(msg.to_s)
    puts "Service discovered: #{msg.inspect}"
    query(context, result[1], result[2]) if result
  else
    puts "Error msg: #{msg.inspect}"
  end

end
