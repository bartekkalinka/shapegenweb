/**
 * Created by bka on 21.03.15.
 */
package pl.bka.shapegenweb

import org.scalatest.{Matchers, FlatSpec}

class NoiseSpec extends FlatSpec with Matchers {
  val noise = Noise(Array(Array(211, 424), Array(523, 989)), 0)
  val dbl = noise.double
  dbl.noise.toList.map(_.toList) should be (List(
    List(211, 211, 424, 424),
    List(211, 211, 424, 424),
    List(523, 523, 989, 989),
    List(523, 523, 989, 989)
  ))
  dbl.detail should be (1)
}

class TerrainSpec extends FlatSpec with Matchers {
  val terrain = new Terrain

  "Terrain.get(x, y, detail)" should "cache results" in {
    terrain.reset
    val noise1 = terrain.get(49, 51)
    val noise2 = terrain.get(49, 51)
    noise1 should be (noise2)
  }

  "Terrain.get(x, y, detail)" should "size noise based on detail parameter" in {
    terrain.reset
    val noise1 = terrain.get(49, 51)
    val noise2 = terrain.moreDetail(49, 51)
    noise1.noise.length should be (noise2.noise.length / 2)
  }

  "Terrain.get(x, y)" should "get detail 0 when used 1st time" in {
    terrain.reset
    val noise = terrain.get(49, 51)
    noise.noise.length should be (Noise.baseSize)
    noise.detail should be (0)
  }

  "Terrain.get(x, y)" should "get max detail version of given sector" in {
    terrain.reset
    val noise1 = terrain.get(49, 51)
    val noise2 = terrain.moreDetail(49, 51)
    val noise3 = terrain.get(49, 51)
    noise3 should be (noise2)
    noise3.detail should be (1)
  }
}