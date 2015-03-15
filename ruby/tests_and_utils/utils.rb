module MyConfig
  # generation config
  @@iter = 3
  @@size = 48
  # mongodb config
  @@dbconfig = {
    :dbname => 'local',
    :collections => {:basenoise => 'basenoise', :shape => 'shape'},
    :host => 'localhost',
    :auth => {:needed => false}
  }
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

module Utils
  def cooplus(coord1, coord2)
    [coord1,coord2].transpose.map {|x| x.reduce(:+)}
  end

  def coominus(coord1, coord2)
    [coord1,coord2].transpose.map {|x| x.reduce(:-)}
  end
end