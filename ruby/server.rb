require 'rbczmq'
require 'socket'

nickname   = ARGV[0] || "@febeling"
port       = 6666
ip         = Socket.ip_address_list.find { |intf| intf.ipv4_private? }
last_octet = ip.ip_address.split(".").last
pattern    = /hello/i.freeze

context = ZMQ::Context.new

hello_server = Thread.new do

  socket = context.socket(:ROUTER)
  socket.rcvtimeo = 5_000
  socket.bind("tcp://0.0.0.0:#{port}")

  while true
    msgs = []
    sender = socket.recv
    payload = socket.recv
    puts "> #{payload.inspect} (from: #{sender.inspect})"

    if pattern.match(payload)
      answer = "Hello from #{nickname}"
      puts "< #{answer.inspect}"
      socket.sendm sender
      socket.send answer
    elsif ZMQ.error
      puts "Timeout, continue"
    else
      puts "Protocol error: #{payload.inspect}"
      socket.send "Error"
    end
    sleep 0.1
  end

end

discovery_server = Thread.new do

  me = "#{last_octet}:#{port}"
  socket = context.socket(ZMQ::PUB)
  socket.bind("tcp://*:6665")

  while true
    puts "#{Time.now} [discovery] > #{me.inspect}"
    socket.send me
    sleep 2
  end

end

[hello_server, discovery_server].each(&:join)

