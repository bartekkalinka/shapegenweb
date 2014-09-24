# test_perf.rb
require './shape_generator'

def timing
  (Time.now.to_f * 1000).floor
end

def test_generate_performance
  sizex, sizey, iter, cutoff = [50, 50, 3, false]
  gen = ShapeGenerator.new
  timing_start = timing
  shape, basenoise = gen.generate_shape(sizex, sizey, iter, cutoff)
  timing_generate = timing
  direction = :N
  (0 ... 20).each { shape, basenoise = gen.shift_and_generate(basenoise, direction, iter, cutoff) }
  timing_shift_and_generate = timing
  puts "generate: " + (timing_generate - timing_start).to_s + " ms"
  puts "20 x shift and generate: " + (timing_shift_and_generate - timing_generate).to_s + " ms"
end

test_generate_performance