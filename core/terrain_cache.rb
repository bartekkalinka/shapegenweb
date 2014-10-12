class TerrainCache
  include MyConfig
  @@db_cache = DbCache.new(@@dbname, @@collections)

  def self.get_shape(x, y)
    @@db_cache.shape_get([x, y])
  end
end