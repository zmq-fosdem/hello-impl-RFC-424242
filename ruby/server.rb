require 'ffi-rzmq'
require 'socket'

port       = 6666
ip         = Socket.ip_address_list.find { |intf| intf.ipv4_private? }
last_octet = ip.ip_address.split(".").last
pattern    = /hello/i.freeze

hello_server = Thread.new do

  context = ZMQ::Context.new
  socket = context.socket(ZMQ::ROUTER)
  socket.setsockopt(ZMQ::RCVTIMEO, 10_000)
  socket.bind("tcp://0.0.0.0:#{port}")

  while true
    puts "hello loop"

    msgs = []
    socket.recv_strings msgs
    puts "hello server received: #{msgs}"

    if pattern.match(msgs.last)
      puts "."
      rc = socket.send_strings [msgs.first, "Cat bus"]
      puts "sending hello answer: #{rc.inspect}"
    else
      puts "error: #{msgs.inspect}"
      socket.send_string "Error"
    end

    sleep 1
  end

end

ad_server = Thread.new do

  me = "#{last_octet}:#{port}"

  context = ZMQ::Context.new
  socket = context.socket(ZMQ::PUB)
  socket.bind("tcp://0.0.0.0:6665")

  while true
    puts "#{Time.now} [ad] #{me}"
    socket.send_string me
    sleep 2
  end

end

[hello_server, ad_server].each(&:join)

