module MyConfig
  # generation config
  @@iter = 3
  @@size = 48
  # mongodb config
  @@dbname = 'local'
  @@collections = {:basenoise => 'basenoise', :shape => 'shape'}
end

module Timing
  @@timingTab = {}

  def timingTab=(tab)
    @@timingTab = tab
  end
  
  def timingTab
    @@timingTab
  end

  def timing
    (Time.now.to_f * 1000).floor
  end

  def log_timing(message, input_timing = timing)
    @@timingTab[message] = input_timing
  end
end