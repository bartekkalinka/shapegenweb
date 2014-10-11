require 'set'

class TerrainGenerator
  include Utils

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

  def shape_basenoise_offset(coord)
    sbase = basenoise_to_shape_coord(shape_to_basenoise_coord(coord))
    coominus(coord, sbase)
  end

  def get_basenoise_tileset(upperLeftShape, lowerRightShape)
    result = Set.new
    get_tileset(upperLeftShape, lowerRightShape) { |coord|
        bcoord = shape_to_basenoise_coord(coord)
        [0, 1].product([0, 1]).each { |dc|
          result.add(cooplus(bcoord, dc))
        }
    }
    return result.to_a
  end

  def get_shapes_tileset(upperLeftShape, lowerRightShape)
    result = []
    get_tileset(upperLeftShape, lowerRightShape) { |coord| result << coord }
    return result
  end

  def generate_basenoise(tileset)
    tileset.each { |coord|
      puts "basenoise " + coord.to_s
      basenoise = @shapegen.get_noise_table(@size)
      @dbcache.basenoise_put(basenoise, coord)
    }
  end

  def generate_shapes(tileset)
    tileset.each { |coord|
      puts "shape " + coord.to_s
      bcoord = shape_to_basenoise_coord(coord)
      basenoisetab = (0..1).collect { |dx| (0..1).collect { |dy| @dbcache.basenoise_get(cooplus(bcoord, [dx, dy])) }}  
      puts "shape basenoise offset " + shape_basenoise_offset(coord).to_s
      shiftbnoise = @shapegen.get_shifted_basenoise(basenoisetab, shape_basenoise_offset(coord))
      shape = @shapegen.shape_from_basenoise(shiftbnoise, @iter)
      @dbcache.shape_put(shape, coord)
    }
  end

  def generate(upperLeft, lowerRight)
    puts "start"
    generate_basenoise(get_basenoise_tileset(upperLeft, lowerRight))
    puts "basenoise done"
    generate_shapes(get_shapes_tileset(upperLeft, lowerRight))
    puts "end"
  end

  private
  def get_tileset(upperLeftShape, lowerRightShape)
    (upperLeftShape[0]..lowerRightShape[0]).each { |x|
      (upperLeftShape[1]..lowerRightShape[1]).each { |y|
        yield [x, y]
      }
    }
  end

end