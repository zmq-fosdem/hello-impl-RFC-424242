require 'ffi-rzmq'

def query(context, address, port)

  dealer = context.socket(ZMQ::DEALER)
  server = "tcp://192.168.1.#{address}:#{port}"
  puts "query ... hello server address: #{server}"

  dealer.setsockopt(ZMQ::RCVTIMEO, 5_000)
  dealer.setsockopt(ZMQ::SNDTIMEO, 5_000)
  dealer.connect(server)

  dealer.send_string "Hello"

  msgs = []
  dealer.recv_strings(msgs)
  puts "#{server} said: '#{msgs.inspect}'"
  dealer.close

end

context = ZMQ::Context.new
socket  = context.socket(ZMQ::SUB)
socket.setsockopt(ZMQ::SUBSCRIBE, "")
socket.setsockopt(ZMQ::RCVHWM, 20)
socket.setsockopt(ZMQ::RCVTIMEO, 5_000)

pattern = /^(\d{1,3}):(\d{1,5})$/

while true
  for ip in [9]

    address = "tcp://192.168.1.#{ip}:6665"
    rc      = socket.connect(address)
    puts "subscribed #{address}: OK"

    msg = ''
    rc = socket.recv_string(msg)
    puts "received: #{msg.to_s} #{rc.inspect}"

    if msg.to_i != -1 && msg.to_s.size > 0
      result = pattern.match(msg.to_s)
      ok = if result
             "ok (address: #{result[1]}, port: #{result[2]})"
           else
             "nope"
           end
      puts "discovered: #{msg.to_s} : #{ok}"
      query(context, result[1], result[2]) if result
    else
      puts "error msg: #{msg.inspect}"
    end

  end
end
