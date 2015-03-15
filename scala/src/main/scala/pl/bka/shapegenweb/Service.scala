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

object ShapeJsonProtocol extends DefaultJsonProtocol {
  implicit val shapeFormat = jsonFormat1(Shape.apply)
}

// this trait defines our service behavior independently from the service actor
trait ShapeGenService extends HttpService {
  import ShapeJsonProtocol._
  val sampleShape = Shape(Array(Array(false, true), Array(true, false)))
  val sampleJson = sampleShape.toJson

  val mainRoute =
    pathPrefix("") {
      getFromResourceDirectory("client")
    } ~
    path("shape" / IntNumber / IntNumber) { (x, y) =>
      get {
        complete {
          sampleJson.toString()
        }
      }
    }
}