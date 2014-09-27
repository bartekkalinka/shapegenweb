require 'mongo'

class TerrainCache
  include Mongo

  @@coord = [0, 0]

  def self.generate(sizex, sizey, iter, cutoff)
    gen = ShapeGenerator.new({})
    gen.generate_shape(sizex, sizey, iter, cutoff)
  end

  def self.shift_and_generate(basenoise, direction, iter, cutoff, timingTab)
    update_coordinates(direction)
    gen = ShapeGenerator.new(timingTab)
    store(gen.shift_and_generate(basenoise, direction, iter, cutoff))
  end

  def self.update_coordinates(direction)
    update_matrix = { :N => [0, -1], :E => [1, 0], :S => [0, 1], :W => [-1, 0] }
    [0, 1].each { |i| @@coord[i] = @@coord[i] + update_matrix[direction][i] }
  end

  def self.store(shift_result)
    shape, basenoise = shift_result
    client = MongoClient.new #TODO store connection in class variable
    db = client['local']
    coll = db['firstTest']
    rec = { :x => @@coord[0], :y => @@coord[1], :shape => shape, :basenoise => basenoise }
    coll.insert rec
    return shift_result
  end
end