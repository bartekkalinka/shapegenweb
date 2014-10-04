module MyConfig
  @@iter = 3

  def iter=(it)
    @@iter = it
  end
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