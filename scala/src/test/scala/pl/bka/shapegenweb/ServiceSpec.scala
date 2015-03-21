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

    "return sector json (with detail API)" in {
      Get("/sector/49/51/2") ~> mainRoute ~> check {
        responseAs[String] must contain("{") and contain("noise") and contain("[")
      }
    }

    "leave GET requests to other paths unhandled" in {
      Get("/kermit") ~> mainRoute ~> check {
        handled must beFalse
      }
    }
  }
}
