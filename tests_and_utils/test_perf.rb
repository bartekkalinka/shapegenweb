# test_perf.rb
require './utils'
require '../core/shape_generator'

include Timing
include MyConfig

def test_generate_performance
  gen = ShapeGenerator.new
  log_timing("timing_start")
  shape, basenoise = gen.generate_shape(@@size, @@size, @@iter)
  log_timing("timing_generate")
  direction = :N
  shape, basenoise = gen.shift_and_generate(basenoise, direction, @@iter)
  log_timing("timing_shift_and_generate")
  puts "generate: " + (Timing.timingTab["timing_generate"] - Timing.timingTab["timing_start"]).to_s + " ms"
  puts "shift and generate: " + (Timing.timingTab["timing_shift_and_generate"] - Timing.timingTab["timing_generate"]).to_s + " ms"
end

test_generate_performance