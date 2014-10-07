require 'mongo'

class DbCache
  include Mongo
  include Timing

  def initialize(dbname, collections)
    @collections = collections
    @client = MongoClient.new
    @db = @client[dbname]
  end

  private def get(type, x, y)
    coll = @db[@collections[type]
    cur = coll.find( { :x => x, :y => y }, {:fields => [type]} )
    if(cur.has_next?)
      doc = cur.next
      log_timing(type.to_s + " exists in cache " + [x, y].to_s)
      return doc[type.to_s]
    else
      log_timing("no cache " + [x, y].to_s)
      return nil
    end
  end

  private def put(type, data, x, y)
    coll = @db[@collections[type]]
    rec = { :x => x, :y => x, type => data }
    coll.insert rec
  end

  def basenoise_put(basenoise, x, y)
    put(:basenoise, basenoise, x, y)
  end

  def basenoise_get(x, y)
    get(:basenoise, x, y)
  end

  def shape_put(shape, x, y)
    put(:shape, shape, x, y)
  end

  def shape_get(x, y)
    get(:shape, x, y)
  end
end