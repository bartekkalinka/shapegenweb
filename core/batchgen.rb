require 'mongo'
require './tests_and_utils/utils'
require './core/terrain_generator'

class BatchGenerator
  include Mongo
  include MyConfig

  def self.generate(upperLeft, lowerRight)
    # TODO
  end
end

BatchGenerator.generate([-5, -5], [5, 5])
