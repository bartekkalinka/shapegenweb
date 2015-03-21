/**
 * Created by bka on 21.03.15.
 */
package pl.bka.shapegenweb

import org.scalatest.{Matchers, FlatSpec}

class CoreSpec extends FlatSpec with Matchers {
  "Terrain.get" should "cache results" in {
    val noise1 = Terrain.get(49, 51, 0)
    val noise2 = Terrain.get(49, 51, 0)
    noise1 should be (noise2)
  }

  "Terrain.get" should "size noise based on detail parameter" in {
    val noise1 = Terrain.get(49, 51, 0)
    val noise2 = Terrain.get(49, 51, 1)
    noise1.noise.length should be (noise2.noise.length / 2)
  }
}