module Timing
  def timing
    (Time.now.to_f * 1000).floor
  end
end