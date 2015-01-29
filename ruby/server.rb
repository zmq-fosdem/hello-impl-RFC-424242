require 'ffi-rzmq'

context = ZMQ::Context.new
socket = context.socket(ZMQ::REP)
socket.bind("tcp://0.0.0.0:6666")

while true
  string = ""
  socket.recv_string string

  if string == "Hello"
    print "."
    socket.send_string "Hello"
  else
    print "x"
    socket.send_string "Error"
  end
end
