# test of Timing module use
require './utils.rb'

include Timing

timing_before = timing
Timing.timingTab = { "start" => timing }
log_timing("timing 2", timing_before)
log_timing("timing 3")
puts Timing.timingTab.to_s