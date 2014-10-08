require 'set'

class TerrainGenerator
  def initialize(size, iter, dbcache)
    @size = size
    @iter = iter
    @shiftstep = size / (2 ** iter)
    @dbcache = dbcache
    @shapegen = ShapeGenerator.new
  end

  def basenoise_to_shape_coord(coord)
    coord.collect { |c| c * @shiftstep }
  end

  def shape_to_basenoise_coord(coord)
    coord.collect { |c| (c / @shiftstep).floor }
  end

  def get_basenoise_tileset(upperLeftShape, lowerRightShape)
    result = Set.new
    (upperLeftShape[0]..lowerRightShape[0]).collect { |x|
      (upperLeftShape[1]..lowerRightShape[1]).collect { |y|
        result.add(shape_to_basenoise_coord([x, y]))
      }
    }
    return result.to_a
  end

  def generate_basenoise(tileset)
    tileset.each { |x, y|
      basenoise = @shapegen.get_noise_table(@size)
      @dbcache.basenoise_put(basenoise, x, y)
    }
  end

  def generate(upperLeft, lowerRight)
    # basenoise collection
    generate_basenoise(get_basenoise_tileset(upperLeft, lowerRight))
    # TODO shape collection
  end
end