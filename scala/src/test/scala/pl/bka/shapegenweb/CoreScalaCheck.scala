package pl.bka.shapegenweb

import org.scalacheck.{Properties, Gen}
import org.scalacheck.Prop.{forAll, BooleanOperators}

/**
 * Created by bka on 22.03.15.
 */


object TerrainCacheSpec extends Properties("Terrain") {
  val x = 49
  val y = 51

  val terrain = new Terrain

  def initialState() = {
    terrain.reset
  }

  def checkMaxToCacheConsistency: Boolean = {
    terrain.detailMax.get(x, y) match {
      case Some(detail) => terrain.noiseCache.keys.exists(_ == (x, y, detail))
      case None => !terrain.noiseCache.keys.find({case (a, b, _) => (a, b) == (x, y)}).isDefined
    }
  }

  def checkCacheToMaxConsistency: Boolean = {
    terrain.noiseCache.keys.filter({case (a, b, _) => (a, b) == (x, y)}).map(_._3).toList match {
      case Nil => !terrain.detailMax.get(x, y).isDefined
      case details => terrain.detailMax.getOrElse((x, y), -1) == details.max
    }
  }


  sealed trait MyCommand {
    def run: Unit
  }

  case object Get2 extends MyCommand {
    def run = terrain.get(x, y)
  }

  case class Get3(detail: Int) extends MyCommand {
    def run = terrain.get(x, y, detail)
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
