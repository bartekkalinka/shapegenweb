/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]], detail: Int) {
  override def toString = "Noise " + noise.foldLeft("")((s, a) => s + "[" + a.foldLeft("")((s, i) => s + i + ", ") + "], ")

  def moreDetail: Noise = {
    assert(detail >= 0 && detail <= 3)
    val size = Noise.detailSize(detail + 1)
    Noise(Array.fill(size, size)(Random.nextInt(1000)), detail + 1)
  }
}


object Noise {
  val baseSize = 6
  val detailMultsMap = Map(0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)

  def base: Noise = {
    Noise(Array.fill(baseSize, baseSize)(Random.nextInt(1000)), 0)
  }

  def detailSize(detail: Int) = Noise.baseSize * Noise.detailMultsMap(detail)
}

class Terrain {
  val noiseCache = new mutable.HashMap[(Int, Int), Noise]()

  def reset = {
    noiseCache.clear()
  }

  def moreDetail(x: Int, y: Int): Noise =  {
    val newNoise = noiseCache.get(x, y) match {
      case Some(noise) => noise.moreDetail
      case None => Noise.base
    }
    noiseCache.put((x, y), newNoise)
    newNoise
  }

  def get(x: Int, y: Int): Noise = noiseCache.getOrElseUpdate((x, y), Noise.base)

}