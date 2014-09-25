# test_perf.rb
require './utils'
require './shape_generator'

include Timing

def test_generate_performance
  sizex, sizey, iter, cutoff = [50, 50, 3, false]
  gen = ShapeGenerator.new({})
  timing_start = timing
  shape, basenoise = gen.generate_shape(sizex, sizey, iter, cutoff)
  timing_generate = timing
  direction = :N
  shape, basenoise = gen.shift_and_generate(basenoise, direction, iter, cutoff)
  timing_shift_and_generate = timing
  puts "generate: " + (timing_generate - timing_start).to_s + " ms"
  puts "shift and generate: " + (timing_shift_and_generate - timing_generate).to_s + " ms"
end

test_generate_performance