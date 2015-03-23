/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]], detail: Int) {
  override def toString = "Noise " + noise.foldLeft("")((s, a) => s + "[" + a.foldLeft("")((s, i) => s + i + " ") + "], ") + " detail " + detail

  def double: Noise =
    Noise(noise.flatMap(a => Array(a.flatMap(b => Array(b, b)), a.flatMap(b => Array(b, b)))), detail + 1)

  def safeGet(x: Int, y: Int) = {
    if(x < 0 || x >= noise.size || y < 0 || y >= noise(0).size) 500 else noise(x)(y)
  }

  def smooth: Noise =
    Noise(
      Range(0, noise.size).map({ x => Range(0, noise(0).size).map({ y =>
        Noise.smoothCoordMatrix.foldLeft[Int](0) {
          (sum, d) =>
            d match {
              case ((dx, dy), i) => sum + safeGet(x + dx, y + dy) / Noise.smoothWeightMatrix(i)
            }
        }}).toArray
      }).toArray
    , detail)

  def moreDetail: Noise = {
    assert(detail >= 0 && detail <= 3)
    double.smooth
  }
}


object Noise {
  val baseSize = 6
  val detailMultsMap = Map(0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)

  val smoothMatrix = List.tabulate(3, 3)((a, b) => (a - 1, b - 1)).flatten
  val smoothCoordMatrix = smoothMatrix.zipWithIndex
  val smoothWeightMatrix = smoothMatrix.map {case (a, b) => Math.pow(2, a.abs + b.abs + 2).toInt}

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