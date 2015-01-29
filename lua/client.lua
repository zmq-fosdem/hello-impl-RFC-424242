-- Hello World client

local zmq = require "lzmq"
local port = arg[1]

print("Connecting to hello world server ...")
local context = zmq.context()
local requester, err = context:socket{zmq.REQ,
  connect = "tcp://localhost:" .. port
  }

print ("Sending Hello")
requester:send("Hello")
local buffer = requester:recv()
print("Received: " .. buffer)
