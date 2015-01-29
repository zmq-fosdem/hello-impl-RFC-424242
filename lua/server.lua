local zmq = require "lzmq"

local port = arg[1]
local context = zmq.context()
local responder, err = context:socket{zmq.REP, bind = "tcp://*:" .. port}
zmq.assert(responder, err)

print("Hello World server running")

while true do
   local buffer = zmq.assert(responder:recv())
   if buffer == "Hello" then
      responder:send("World")
   else
      responder:send("Error")
   end
end
