package pl.bka.shapegenweb

import org.scalatest.{Matchers, FlatSpec}
import spray.testkit.ScalatestRouteTest
import spray.http.StatusCodes._

class ShapeGenServiceSpec extends FlatSpec with Matchers with ScalatestRouteTest with ShapeGenService {
  def actorRefFactory = system
  
  "ShapeGenService" should "return main page" in {
    Get("/index.html") ~> mainRoute ~> check {
      responseAs[String] should include("Moving terrain")
    }
  }

  it should "return sector json (with-detail API)" in {
    Get("/sector/49/51/2") ~> mainRoute ~> check {
      responseAs[String] should include ("{")
      responseAs[String] should include ("noise")
      responseAs[String] should include ("[")
    }
  }

  it should "return 422 when detail out of range" in {
    Get("/sector/49/51/4") ~> mainRoute ~> check {
      status should be (UnprocessableEntity)
      responseAs[String] should be ("detail out of 0,1,2,3 range")
    }
  }

  it should "return sector json (without-detail API)" in {
    Get("/sector/49/51") ~> mainRoute ~> check {
      responseAs[String] should include ("{")
      responseAs[String] should include ("noise")
      responseAs[String] should include ("[")
    }
  }

  it should "leave GET requests to other paths unhandled" in {
    Get("/kermit") ~> mainRoute ~> check {
      handled should be (false)
    }
  }

}
