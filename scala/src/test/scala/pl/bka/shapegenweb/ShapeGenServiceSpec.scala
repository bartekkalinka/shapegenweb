package pl.bka.shapegenweb

import org.specs2.mutable.Specification
import spray.testkit.Specs2RouteTest
import spray.http._
import StatusCodes._

class ShapeGenServiceSpec extends Specification with Specs2RouteTest with ShapeGenService {
  def actorRefFactory = system
  
  "ShapeGenService" should {

    "return main page" in {
      Get("/index.html") ~> mainRoute ~> check {
        responseAs[String] must contain("Moving terrain")
      }
    }

    "return shape json" in {
      Get("/shapegenweb/49/51") ~> mainRoute ~> check {
        responseAs[String] must contain("{") and contain("shape") and contain("[")
      }
    }

    "leave GET requests to other paths unhandled" in {
      Get("/kermit") ~> mainRoute ~> check {
        handled must beFalse
      }
    }
  }
}
