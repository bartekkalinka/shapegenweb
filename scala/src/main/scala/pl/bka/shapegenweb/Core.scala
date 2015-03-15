/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.util.Random

case class Noise(noise: Array[Array[Int]])

object Config {
  val size = 6
}

object Noise {
  import Config._

  def get = Noise(Range(0, size).map(i => Range(0, size).map(j => Random.nextInt(1000)).toArray).toArray)
}