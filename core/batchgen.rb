require './tests_and_utils/utils'
require './core/terrain_generator'
require './core/dbcache'

class BatchGenerator
  include MyConfig

  def self.generate(upperLeft, lowerRight)
    dbcache = DbCache.new(@@dbname, @@collections)
    terraingen = TerrainGenerator(@@size, @@iter, dbcache)
    # TODO
  end
end

BatchGenerator.generate([-5, -5], [5, 5])
