/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]])

object Config {
  val baseSize = 6
  val detailMultsMap = Map(0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8, 4 -> 16)
}

object Noise {
  import Config._

  def get(detail: Int): Noise = {
    val size = baseSize * detailMultsMap(detail)
    Noise(Array.fill(size, size)(Random.nextInt(1000)))
  }
}

object Terrain {
  val map = new mutable.HashMap[(Int, Int, Int), Noise]()

  def get(x: Int, y: Int, detail: Int) = map.getOrElseUpdate((x, y, detail), Noise.get(detail))
}