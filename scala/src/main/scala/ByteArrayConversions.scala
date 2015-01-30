/**
 * @author Alexander De Leon <me@alexdeleon.name>
 */
object ByteArrayConversions {

  implicit def byteArrayToString(bytes: Array[Byte]): String = new String(bytes)

}
