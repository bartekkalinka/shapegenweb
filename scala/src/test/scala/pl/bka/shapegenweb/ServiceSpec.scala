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

  it should "return sector json (moreDetail)" in {
    Get("/sector/49/51/moreDetail") ~> mainRoute ~> check {
      responseAs[String] should include ("{")
      responseAs[String] should include ("noise")
      responseAs[String] should include ("[")
    }
  }

  it should "return sector json (without-detail API)" in {
    Get("/sector/49/51/get") ~> mainRoute ~> check {
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
