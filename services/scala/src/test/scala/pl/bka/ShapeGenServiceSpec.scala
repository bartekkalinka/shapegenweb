package pl.bka

import org.specs2.mutable.Specification
import spray.testkit.Specs2RouteTest
import spray.http._
import StatusCodes._

class ShapeGenServiceSpec extends Specification with Specs2RouteTest with ShapeGenService {
  def actorRefFactory = system
  
  "MyService" should {

    "return a greeting for GET requests to hello.html path" in {
      Get("/hello.html") ~> mainRoute ~> check {
        responseAs[String] must contain("Say hello")
      }
    }

    "leave GET requests to other paths unhandled" in {
      Get("/kermit") ~> mainRoute ~> check {
        handled must beFalse
      }
    }
  }
}
