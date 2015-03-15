class TerrainCache
  include MyConfig
  @@db_cache = DbCache.new(@@dbconfig)

  def self.get_shape(x, y)
    @@db_cache.shape_get([x, y])
  end
end