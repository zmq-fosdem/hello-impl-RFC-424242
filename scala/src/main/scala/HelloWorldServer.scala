import org.zeromq.ZMQ
import ByteArrayConversions._

object HelloWorldServer extends App {

  val context = ZMQ.context(1)
  val reply = "Hello World"

  //  Socket to talk to clients
  val responder = context.socket(ZMQ.REP)
  responder.bind("tcp://*:6666")

  while (true) {
    // Wait for next request from the client
    val request: String = responder.recv(0)
    println(s"Received $request")

    // Send reply back to client
    responder.send(reply.getBytes(), 0)
  }
  responder.close()
  context.term()

}
