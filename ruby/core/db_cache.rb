require 'mongo'

class DbCache
  include Mongo
  include Timing

  def initialize(config)
    @collections = config[:collections]
    @client = MongoClient.new(config[:host])
    @db = @client[config[:dbname]]
    if(config[:auth][:needed])
      @db.authenticate(config[:auth][:user], config[:auth][:password])
    end
  end

  def basenoise_put(basenoise, coord)
    put(:basenoise, basenoise, coord)
  end

  def basenoise_get(coord)
    get(:basenoise, coord)
  end

  def shape_put(shape, coord)
    put(:shape, shape, coord)
  end

  def shape_get(coord)
    get(:shape, coord)
  end

  def clear
    @db[@collections[:basenoise]].remove({})
    @db[@collections[:shape]].remove({})
  end

  private
  def get(type, coord)
    coll = @db[@collections[type]]
    cur = coll.find( { :x => coord[0], :y => coord[1] }, {:fields => [type]} )
    if(cur.has_next?)
      doc = cur.next
      log_timing(type.to_s + " exists in cache " + coord.to_s)
      return doc[type.to_s]
    else
      log_timing("no cache " + coord.to_s)
      return nil
    end
  end

  private 
  def put(type, data, coord)
    coll = @db[@collections[type]]
    rec = { :x => coord[0], :y => coord[1], type => data }
    coll.insert rec
  end
end