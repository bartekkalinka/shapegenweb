require './shape_generator'

class ShapeGeneratorTest
  attr_reader :testgen, :testnoisetab, :testshapetab, :testnilshapetab, :testchunkstab

  def initialize
    @testgen = ShapeGenerator.new(4, 3)
    @testnoisetab = [[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]]
    @testshapetab = [[false, true, true], [true, true, false], [false, true, false], [false, true, false]]
    @testnilshapetab = [[nil, true, true], [true, true, false], [false, true, nil], [nil, true, false]]
    @testchunkstab = [[false, true, true], [false, false, false], [false, false, true], [false, true, true]]
  end

end

RSpec.describe ShapeGenerator do

  it "get_noise_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.get_noise_table.flatten.index { |elem| elem < 0 or elem > 1000 }).to eq(nil)
  end

  it "safe_noise_set" do
    t = ShapeGeneratorTest.new
    t.testgen.safe_noise_set(t.testnoisetab, 3, 2, 78)
    expect(t.testnoisetab[3][2]).to eq(78)
    t.testgen.safe_noise_set(t.testnoisetab, 20, 4, 78) # no error -> test passed
  end

  it "scale_noise_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.scale_noise_table(t.testnoisetab)).to eq([[324, 324, 628], [324, 324, 628], [98, 98, 882], [98, 98, 882]])
  end

  it "safe_noise_test" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.safe_noise_test(t.testnoisetab, 3, 2)).to eq(70)
    expect(t.testgen.safe_noise_test(t.testnoisetab, 20, 4)).to eq(0)
  end

  it "get_smooth_noise_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.get_smooth_noise_table(t.testnoisetab)).to eq([[226, 394, 295], [289, 550, 443], [298, 432, 283], [231, 235, 97]])
  end

  it "build_empty_shape" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.build_empty_shape.flatten.index { |elem| elem != false }).to eq(nil)
  end

  it "build_empty_shape_nil" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.build_empty_shape_nil.flatten.index { |elem| elem != nil }).to eq(nil)
  end

  it "weight" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.weight(t.testshapetab)).to eq(6)
  end

  it "find_first_point" do
    t = ShapeGeneratorTest.new
    x, y = t.testgen.find_first_point(t.testshapetab)
    expect(t.testshapetab[x][y]).to eq(true)
  end

  it "substract_shape" do
    t = ShapeGeneratorTest.new
    subshapetab = [[false, true, false], [true, false, false], [false, true, false], [false, true, false]]
    expect(t.testgen.substract_shape(t.testshapetab, subshapetab)).to eq( 
      [[false, false, true], [false, true, false], [false, false, false], [false, false, false]])
  end

  it "denil_chunk" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.denil_chunk(t.testnilshapetab)).to eq(t.testshapetab)
  end

  it "divide_into_whole_shapes" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.divide_into_whole_shapes(t.testchunkstab)).to eq(
      [[[false, true, true], [false, false, false], [false, false, false], [false, false, false]],
       [[false, false, false], [false, false, false], [false, false, true], [false, true, true]]]
    )
  end

  it "cutoff_loose_fragments" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.cutoff_loose_fragments(t.testchunkstab)).to eq(
      [[false, false, false], [false, false, false], [false, false, true], [false, true, true]]
    )
  end

end

