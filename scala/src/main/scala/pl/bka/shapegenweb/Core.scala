/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]])

object Config {
  val size = 6
}

object Noise {
  import Config._

  def get: Noise = Noise(Array.fill(size, size)(Random.nextInt(1000)))
}

object Terrain {
  val map = new mutable.HashMap[(Int, Int), Noise]()

  def get(x: Int, y: Int) = map.getOrElseUpdate((x, y), Noise.get)
}