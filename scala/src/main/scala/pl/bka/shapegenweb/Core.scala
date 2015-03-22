/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]]) {
  override def toString = "Noise " + noise.foldLeft("")((s, a) => s + "[" + a.foldLeft("")((s, i) => s + i + ", ") + "], ")
}

object Config {
  val baseSize = 6
  val detailMultsMap = Map(0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)
}

object Noise {
  import Config._

  //val empty = Noise(Array(Array()))

  def get(detail: Int): Noise = {
    val size = baseSize * detailMultsMap(detail)
    Noise(Array.fill(size, size)(Random.nextInt(1000)))
  }
}

object Terrain {
  val noiseCache = new mutable.HashMap[(Int, Int, Int), Noise]()
  val detailMax = new mutable.HashMap[(Int, Int), Int]()

  def reset = {
    noiseCache.clear()
    detailMax.clear()
  }

  def get(x: Int, y: Int, detail: Int): Noise =  {
    noiseCache.get((x, y, detail)) match {
      case Some(noise) => noise
      case None =>
          val noise = Noise.get(detail)
          noiseCache.put((x, y, detail), noise)
          val newMax = detailMax.get((x, y)) match {
            case Some(maxDetail) => if(detail > maxDetail) detail else maxDetail
            case None => detail
          }
          detailMax.put((x, y), newMax)
          noise
    }
  }

  def get(x: Int, y: Int): Noise = get(x, y, detailMax.getOrElse((x, y), 0))
}