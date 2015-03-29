/**
 * Created by bka on 15.03.15.
 */
package pl.bka.shapegenweb

import scala.collection.mutable
import scala.util.Random

case class Noise(noise: Array[Array[Int]], detail: Int, level: Int) {
  override def toString = "Noise " + noise.foldLeft("")((s, a) => s + "[" + a.foldLeft("")((s, i) => s + i + " ") + "], ") + " detail " + detail

  def double: Noise =
    Noise(noise.flatMap(a => Array(a.flatMap(b => Array(b, b)), a.flatMap(b => Array(b, b)))), Noise.levDetail(level + 1), level + 1)

  def smooth(safeGet: (Array[Array[Int]], Int, Int) => Int): Noise =
    Noise(
      Range(0, noise.size).map({ x => Range(0, noise(0).size).map({ y =>
        Noise.smoothCoordMatrix.foldLeft[Int](0) {
          (sum, d) =>
            d match {
              case ((dx, dy), i) => sum + safeGet(noise, x + dx, y + dy) / Noise.smoothWeightMatrix(i)
            }
        }}).toArray
      }).toArray
    , Noise.levDetail(level + 1), level + 1)

  def nextLevel(safeGet: (Array[Array[Int]], Int, Int) => Int): Noise = if(level % 2 == 0) double else smooth(safeGet)
}


object Noise {
  val baseSize = 6
  val detailMultsMap = Map(0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8)

  val neighboursMatrix = List.tabulate(3, 3)((a, b) => (a - 1, b - 1)).flatten
  val smoothCoordMatrix = neighboursMatrix.zipWithIndex
  val smoothWeightMatrix = neighboursMatrix.map {case (a, b) => Math.pow(2, a.abs + b.abs + 2).toInt}

  def base: Noise = {
    Noise(Array.fill(baseSize, baseSize)(Random.nextInt(1000)), 0, 0)
  }

  def detailSize(detail: Int) = Noise.baseSize * Noise.detailMultsMap(detail)

  def levDetail(lev: Int): Int = (lev + 1) / 2
}

class Terrain {
  val noiseCache = new mutable.HashMap[(Int, Int), (Stream[Noise], Int)]

  def reset = {
    noiseCache.clear()
  }

  private def noiseStream(x: Int, y: Int): Stream[Noise] = {
    def localGet = safeGet(x, y)
    Stream.iterate(Noise.base)(_.nextLevel(localGet))
  }

  private def getCurrent(x: Int, y: Int): (Stream[Noise], Int) = {
    noiseCache.get(x, y) match {
      case Some((stream, level)) => (stream, level)
      case None =>
        val stream = noiseStream(x, y)
        noiseCache.put((x, y), (stream, 0))
        (stream, 0)
    }
  }

  def safeGet(x: Int, y: Int) =
    (noise: Array[Array[Int]], a: Int, b: Int) => {
      val (stream, level) = getCurrent(x, y)
      val size = Noise.detailSize(Noise.levDetail(level))
      val (xx, aa) = if (a < 0) (x - 1, a + size) else if (a >= size) (x + 1, a - size) else (x, a)
      val (yy, bb) = if (b < 0) (y - 1, b + size) else if (b >= size) (y + 1, b - size) else (y, b)
      if (xx != x || yy != y) {
        val (stream, level) = getCurrent(xx, yy)
        stream(level).noise(aa)(bb)
      } else {
        noise(a)(b)
      }
    }

  private def nextDetail(level: Int): Int = {
    level + (if(level % 2 == 0) 2 else 1)
  }

  private def reqNeighbourLevel(level: Int): Option[Int] = {
    if(level > 0 && level % 2 == 0) Some(level - 1) else None
  }

  private def setLevel(x: Int, y: Int, newLevel: Int): Unit = {
    val (stream, level) = getCurrent(x, y)
    if(level < newLevel) {
      noiseCache.put((x, y), (stream, newLevel))
      reqNeighbourLevel(newLevel) match {
        case Some(neighLev) =>
          Noise.neighboursMatrix.foreach({case (a, b) => setLevel(x + a, y + b, neighLev)})
        case None => ()
      }
    }
  }

  def moreDetail(x: Int, y: Int): Noise =  {
    val (stream, level) = getCurrent(x, y)
    val newLevel = nextDetail(level)
    setLevel(x, y, newLevel)
    stream(newLevel)
  }

  def get(x: Int, y: Int): Noise = {
    val (stream, level) = getCurrent(x, y)
    stream(level)
  }

}