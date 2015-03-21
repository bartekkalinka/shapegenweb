/**
 * Created by bka on 21.03.15.
 */
package pl.bka.shapegenweb

import org.scalatest.{Matchers, FlatSpec}

class CoreSpec extends FlatSpec with Matchers {
  "Terrain.get(x, y, detail)" should "cache results" in {
    Terrain.reset
    val noise1 = Terrain.get(49, 51, 0)
    val noise2 = Terrain.get(49, 51, 0)
    noise1 should be (noise2)
  }

  "Terrain.get(x, y, detail)" should "size noise based on detail parameter" in {
    Terrain.reset
    val noise1 = Terrain.get(49, 51, 0)
    val noise2 = Terrain.get(49, 51, 1)
    noise1.noise.length should be (noise2.noise.length / 2)
  }

  "Terrain.get(x, y)" should "get detail 0 when used 1st time" in {
    Terrain.reset
    val noise = Terrain.get(49, 51)
    noise.noise.length should be (Config.baseSize)
  }

  "Terrain.get(x, y)" should "get max detail version of given sector" in {
    Terrain.reset
    val noise1 =Terrain.get(49, 51, 0)
    val noise2 = Terrain.get(49, 51, 1)
    val noise3 = Terrain.get(49, 51)
    noise3 should be (noise2)
  }
}