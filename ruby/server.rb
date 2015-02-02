require 'ffi-rzmq'
require 'socket'

nickname   = ARGV[0] || "@febeling"
port       = 6666
ip         = Socket.ip_address_list.find { |intf| intf.ipv4_private? }
last_octet = ip.ip_address.split(".").last
pattern    = /hello/i.freeze

hello_server = Thread.new do

  context = ZMQ::Context.new
  socket = context.socket(ZMQ::ROUTER)
  socket.setsockopt(ZMQ::RCVTIMEO, 30_000)
  socket.bind("tcp://0.0.0.0:#{port}")

  while true
    msgs = []
    rc = socket.recv_strings msgs
    sender, payload = msgs
    puts "> #{payload.inspect}"

    if pattern.match(payload)
      answer = "Hello from #{nickname}"
      puts "< #{answer.inspect}"
      rc = socket.send_strings [sender, answer]
    elsif rc != 0 && ZMQ::Util.errno == ZMQ::EAGAIN
      puts "Timeout, continue"
    else
      puts "Protocol error: #{payload.inspect}"
      socket.send_string "Error"
    end
    sleep 0.1
  end

end

discovery_server = Thread.new do

  me = "#{last_octet}:#{port}"

  context = ZMQ::Context.new
  socket = context.socket(ZMQ::PUB)
  socket.bind("tcp://*:6665")

  while true
    puts "#{Time.now} [discovery] > #{me.inspect}"
    socket.send_string me
    sleep 2
  end

end

[hello_server, discovery_server].each(&:join)

