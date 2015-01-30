import org.zeromq.ZMQ
import ByteArrayConversions._

object HelloWorldClient extends App {

  val endpoint = "tcp://localhost:6666"
  val context = ZMQ.context(1)

  //  Socket to talk to server
  println("Connecting to hello world server…")

  val requester = context.socket(ZMQ.REQ)
  requester.connect(endpoint)

  requester.send("Hello".getBytes)
  val reply: String = requester.recv(0)

  println(s"Received $reply")

  requester.close()
  context.term()

}
