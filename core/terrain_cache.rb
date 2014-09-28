require 'mongo'

class TerrainCache
  include Mongo
  include Timing

  @@coord = [0, 0]
  @@client = MongoClient.new
  @@db = @@client['local']

  def self.generate(sizex, sizey, iter, cutoff)
    shape, basenoise = check_storage
    if(shape == nil)
      gen = ShapeGenerator.new
      shape, basenoise = store(gen.generate_shape(sizex, sizey, iter, cutoff))
    end
    return shape, basenoise
  end

  def self.shift_and_generate(in_basenoise, direction, iter, cutoff)
    update_coordinates(direction)
    log_timing("update_coord " + @@coord.to_s + " dir " + direction.to_s)
    shape, basenoise = check_storage
    if(shape == nil)
      gen = ShapeGenerator.new
      shape, basenoise = store(gen.shift_and_generate(in_basenoise, direction, iter, cutoff))
    end
    return shape, basenoise
  end

  def self.update_coordinates(direction)
    update_matrix = { :N => [0, -1], :E => [1, 0], :S => [0, 1], :W => [-1, 0] }
    [0, 1].each { |i| @@coord[i] = @@coord[i] + update_matrix[direction][i] }
  end

  def self.store(shift_result)
    shape, basenoise = shift_result
    coll = @@db['shapegenweb']
    rec = { :x => @@coord[0], :y => @@coord[1], :shape => shape, :basenoise => basenoise }
    coll.insert rec
    return shift_result
  end

  def self.check_storage
    coll = @@db['shapegenweb']
    cur = coll.find( { :x => @@coord[0], :y => @@coord[1] }, {:fields => [:shape, :basenoise]} )
    if(cur.has_next?)
      log_timing("cache exists " + @@coord.to_s)
      doc = cur.next
    else
      log_timing("no cache " + @@coord.to_s)
      return nil, nil
    end
  end

end