class TerrainGenerator
  def initialize(size, iter, dbcache)
    @size = size
    @iter = iter
    @shiftstep = size / (2 ** iter)
    @dbcache = dbcache
  end

  def basenoise_to_shape_coord(coord)
    coord.collect { |c| c * @shiftstep }
  end

  def shape_to_basenoise_coord(coord)
    coord.collect { |c| (c / @shiftstep).floor }
  end

  def generate(upperLeft, lowerRight)
    # TODO
  end
end