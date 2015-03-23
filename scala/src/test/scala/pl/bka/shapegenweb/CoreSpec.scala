/**
 * Created by bka on 21.03.15.
 */
package pl.bka.shapegenweb

import org.scalatest.{Matchers, FlatSpec}

class CoreSpec extends FlatSpec with Matchers {
  val terrain = new Terrain

  "Terrain.get(x, y, detail)" should "cache results" in {
    terrain.reset
    val noise1 = terrain.get(49, 51, 0)._1
    val noise2 = terrain.get(49, 51, 0)._1
    noise1 should be (noise2)
  }

  "Terrain.get(x, y, detail)" should "size noise based on detail parameter" in {
    terrain.reset
    val noise1 = terrain.get(49, 51, 0)._1
    val noise2 = terrain.get(49, 51, 1)._1
    noise1.noise.length should be (noise2.noise.length / 2)
  }

  "Terrain.get(x, y)" should "get detail 0 when used 1st time" in {
    terrain.reset
    val (noise, detail) = terrain.get(49, 51)
    noise.noise.length should be (Config.baseSize)
    detail should be (0)
  }

  "Terrain.get(x, y)" should "get max detail version of given sector" in {
    terrain.reset
    val noise1 = terrain.get(49, 51, 0)._1
    val noise2 = terrain.get(49, 51, 1)._1
    val (noise3, detail) = terrain.get(49, 51)
    noise3 should be (noise2)
    detail should be (1)
  }

  "Terrain.get(x, y)" should "get max detail regardless of order of inserts" in {
    terrain.reset
    val noise1 = terrain.get(51, 49, 3)._1
    val noise2 = terrain.get(51, 49, 1)._1
    val (noise3, detail) = terrain.get(51, 49)
    noise3 should be (noise1)
    detail should be (3)
  }
}