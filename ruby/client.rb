require 'ffi-rzmq'

context = ZMQ::Context.new
socket = context.socket(ZMQ::REQ)
socket.connect("tcp://127.0.0.1:6666")

while true
  socket.send_string "Hello"
  puts "request"
  response = ""
  socket.recv_string(response)
  puts "response: #{response}"
  sleep 1
end
