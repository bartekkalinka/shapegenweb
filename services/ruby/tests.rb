require './shape_generator'

def assert(condition, errorMessage)
  if not condition
    raise errorMessage
  end
end

class ShapeGeneratorTest

  def setup
    @testgen = ShapeGenerator.new(4, 3)
    @testnoisetab = [[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]]
    @testshapetab = [[false, true, true], [true, true, false], [false, true, false], [false, true, false]]
    @testnilshapetab = [[nil, true, true], [true, true, false], [false, true, nil], [nil, true, false]]
    @testchunkstab = [[false, true, true], [false, false, false], [false, false, true], [false, true, true]]
  end

  def test_get_noise_table
    setup
    assert(!@testgen.get_noise_table.flatten.index { |elem| elem < 0 or elem > 1000 }, "get_noise_table has values out of range")
  end

  def test_safe_noise_set
    setup
    @testgen.safe_noise_set(@testnoisetab, 3, 2, 78)
    assert(@testnoisetab[3][2] == 78, "safe_noise_set does not set")
    @testgen.safe_noise_set(@testnoisetab, 20, 4, 78) # no error -> test passed
  end

  def test_scale_noise_table
    setup
    scaled_noise = @testgen.scale_noise_table(@testnoisetab)
    assert(scaled_noise == [[324, 324, 628], [324, 324, 628], [98, 98, 882], [98, 98, 882]], "scale_noise_table scales incorrectly")
  end

  def test_safe_noise_test
    setup
    assert(@testgen.safe_noise_test(@testnoisetab, 3, 2) == 70, "safe_noise_test reads incorrectly")
    assert(@testgen.safe_noise_test(@testnoisetab, 20, 4) == 0, "safe_noise_test does not return zero for out of bounds params")
  end

  def test_get_smooth_noise_table
    setup
    assert(@testgen.get_smooth_noise_table(@testnoisetab) == [[226, 394, 295], [289, 550, 443], [298, 432, 283], [231, 235, 97]],
      "get_smooth_noise_table smooths incorrectly")
  end

  def test_build_empty_shape
    setup
    assert(!@testgen.build_empty_shape.flatten.index { |elem| elem != false }, "build_empty_shape has non-false values")
  end

  def test_build_empty_shape_nil
    setup
    assert(!@testgen.build_empty_shape_nil.flatten.index { |elem| elem != nil }, "build_empty_shape_nil has non-false values")
  end

  def test_weight
    setup
    assert(@testgen.weight(@testshapetab) == 6, "wrong weight")
  end

  def test_find_first_point
    setup
    x, y = @testgen.find_first_point(@testshapetab)
    assert(@testshapetab[x][y], "found empty first point")
  end

  def test_substract_shape
    setup
    subshapetab = [[false, true, false], [true, false, false], [false, true, false], [false, true, false]]
    assert(@testgen.substract_shape(@testshapetab, subshapetab) == 
      [[false, false, true], [false, true, false], [false, false, false], [false, false, false]],
      "substracts wrong")
  end

  def test_denil_chunk
    setup
    assert(@testgen.denil_chunk(@testnilshapetab) == @testshapetab, "denils wrong")
  end

  def test_divide_into_whole_shapes
    setup
    assert(@testgen.divide_into_whole_shapes(@testchunkstab) ==
      [[[false, true, true], [false, false, false], [false, false, false], [false, false, false]],
       [[false, false, false], [false, false, false], [false, false, true], [false, true, true]]], "divides wrong")
  end

  def test_cutoff_loose_fragments
    setup
    assert(@testgen.cutoff_loose_fragments(@testchunkstab) ==
      [[false, false, false], [false, false, false], [false, false, true], [false, true, true]], "cutoffs wrong")
  end

  def tests
    test_get_noise_table
    test_safe_noise_set
    test_scale_noise_table
    test_safe_noise_test
    test_get_smooth_noise_table
    test_build_empty_shape
    test_build_empty_shape_nil
    test_weight
    test_find_first_point
    test_substract_shape
    test_denil_chunk
    test_divide_into_whole_shapes
    test_cutoff_loose_fragments
  end
end

t = ShapeGeneratorTest.new
t.tests
puts "ok"
