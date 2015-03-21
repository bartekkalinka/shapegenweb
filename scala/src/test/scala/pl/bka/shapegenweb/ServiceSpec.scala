package pl.bka.shapegenweb

import org.specs2.mutable.Specification
import spray.testkit.Specs2RouteTest
import spray.http.StatusCodes._

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

    "return 422 when detail out of range" in {
      Get("/sector/49/51/4") ~> mainRoute ~> check {
        status === UnprocessableEntity
        responseAs[String] === "detail out of 0,1,2,3 range"
      }
    }

    "leave GET requests to other paths unhandled" in {
      Get("/kermit") ~> mainRoute ~> check {
        handled must beFalse
      }
    }
  }
}
