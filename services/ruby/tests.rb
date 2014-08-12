require './shape_generator'

def assert(condition, errorMessage)
  if not condition
    raise errorMessage
  end
end

class ShapeGeneratorTest

  def initialize
    @testgen = ShapeGenerator.new(10, 7)
  end

  def testnoisetab
    @testgen.get_noise_table
  end

  def test_get_noise_table
    assert(@testgen.get_noise_table.flatten.index { |elem| elem < 0 or elem > 1000 } == nil, "get_noise_table has values out of range")
  end

  def test_safe_noise_set
    noisetab = testnoisetab
    @testgen.safe_noise_set(noisetab, 4, 4, 78)
    assert(noisetab[4][4] == 78, "safe_noise_set does not set")
    @testgen.safe_noise_set(noisetab, 20, 4, 78) # no error -> test passed
  end

  def tests
    test_get_noise_table
    test_safe_noise_set
  end
end

t = ShapeGeneratorTest.new
t.tests
puts "ok"
