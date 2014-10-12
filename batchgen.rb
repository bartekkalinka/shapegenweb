require './tests_and_utils/utils'
require './core/shape_generator'
require './core/db_cache'
require './core/terrain_generator'

class BatchGenerator
  include MyConfig

  def self.generate(upperLeft, lowerRight)
    dbcache = DbCache.new(@@dbname, @@collections)
    dbcache.clear
    terraingen = TerrainGenerator.new(@@size, @@iter, dbcache)
    terraingen.generate(upperLeft, lowerRight)
  end
end

BatchGenerator.generate([-2, -2], [2, 2])
