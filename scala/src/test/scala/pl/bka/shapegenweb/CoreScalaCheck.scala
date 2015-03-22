package pl.bka.shapegenweb

import org.scalacheck.{Properties, Gen}
import org.scalacheck.Prop.{forAll, BooleanOperators}

/**
 * Created by bka on 22.03.15.
 */


object TerrainCacheSpec extends Properties("Terrain") {
  val x = 49
  val y = 51

  def initialState() = {
    Terrain.reset
  }

  def checkMaxToCacheConsistency: Boolean = {
    Terrain.detailMax.get(x, y) match {
      case Some(detail) => Terrain.noiseCache.keys.exists(_ == (x, y, detail))
      case None => !Terrain.noiseCache.keys.find({case (a, b, _) => (a, b) == (x, y)}).isDefined
    }
  }

  def checkCacheToMaxConsistency: Boolean = {
    Terrain.noiseCache.keys.filter({case (a, b, _) => (a, b) == (x, y)}).map(_._3).toList match {
      case Nil => !Terrain.detailMax.get(x, y).isDefined
      case details => Terrain.detailMax.getOrElse((x, y), -1) == details.max
    }
  }


  sealed trait MyCommand {
    def run: Unit
  }

  case object Get2 extends MyCommand {
    def run = Terrain.get(x, y)
  }

  case class Get3(detail: Int) extends MyCommand {
    def run = Terrain.get(x, y, detail)
  }

  val myCommandGen = Gen.oneOf(Gen.const(Get2), Gen.choose(0, 3).map(Get3(_)))

  property("noise cache is consistent with map of detail maxima") =
    forAll(Gen.containerOf[List, MyCommand](myCommandGen)) {
      (cmdList: List[MyCommand]) =>
        initialState()
        cmdList.foreach(_.run)
        checkMaxToCacheConsistency :| "max to cache consistency" &&
        checkCacheToMaxConsistency :| "cache to max consistency"
    }

}
