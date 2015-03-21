package pl.bka.shapegenweb

import akka.actor.Actor
import spray.routing._
import spray.json._
import DefaultJsonProtocol._

// we don't implement our route structure directly in the service actor because
// we want to be able to test it independently, without having to spin up an actor
class ShapeGenServiceActor extends Actor with ShapeGenService {

  // the HttpService trait defines only one abstract member, which
  // connects the services environment to the enclosing actor or test
  def actorRefFactory = context

  // this actor only runs our route, but you could add
  // other things here, like request stream processing
  // or timeout handling
  def receive = runRoute(mainRoute)
}

object NoiseJsonProtocol extends DefaultJsonProtocol {
  implicit val shapeFormat = jsonFormat1(Noise.apply)
}

// this trait defines our service behavior independently from the service actor
trait ShapeGenService extends HttpService {
  import NoiseJsonProtocol._

  val mainRoute =
    pathPrefix("") {
      getFromResourceDirectory("client")
    } ~
    path("sector" / IntNumber / IntNumber / IntNumber) { (x, y, detail) =>
      get {
        complete {
          //TODO limit detail range to 0, 1, 2, 3
          Terrain.get(x, y, detail).toJson.toString()
        }
      }
    }
}