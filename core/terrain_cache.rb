class TerrainCache
  def self.generate(sizex, sizey, iter, cutoff)
    gen = ShapeGenerator.new({})
    gen.generate_shape(sizex, sizey, iter, cutoff)
  end

  def self.shift_and_generate(basenoise, direction, iter, cutoff, timingTab)
    gen = ShapeGenerator.new(timingTab)
    gen.shift_and_generate(basenoise, direction, iter, cutoff)
  end
end