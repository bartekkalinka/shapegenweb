require './shape_generator'

class ShapeGeneratorTest
  attr_reader :testgen, :testnoisetab, :testshapetab, :testnilshapetab, :testchunkstab, :testemptyshape

  def initialize
    @testgen = ShapeGenerator.new(4, 3)
    @testnoisetab = [[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]]
    @testshapetab = [[false, true, true], [true, true, false], [false, true, false], [false, true, false]]
    @testnilshapetab = [[nil, true, true], [true, true, false], [false, true, nil], [nil, true, false]]
    @testchunkstab = [[false, true, true], [false, false, false], [false, false, true], [false, true, true]]
    @testemptyshape = [[false, false, false], [false, false, false], [false, false, false], [false, false, false]]
  end

end

RSpec.describe ShapeGenerator do

  it "get_noise_table" do
    t = ShapeGeneratorTest.new
    testnewnoisetab = t.testgen.get_noise_table
    expect(testnewnoisetab.length).to eq(4)
    expect(testnewnoisetab.index { |col| col.length != 3 }).to eq(nil)
    expect(testnewnoisetab.flatten.index { |elem| elem < 0 or elem > 1000 }).to eq(nil)
  end

  it "safe_noise_set" do
    t = ShapeGeneratorTest.new
    t.testgen.safe_noise_set(t.testnoisetab, 3, 2, 78)
    expect(t.testnoisetab[3][2]).to eq(78)
    t.testgen.safe_noise_set(t.testnoisetab, 20, 4, 78) # no error -> test passed
  end

  it "get_zeros_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.get_zeros_table.flatten.index { |elem| elem != 0 }).to eq(nil)
  end

  it "scale_noise_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.scale_noise_table([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[882, 882, 901], [882, 882, 901], [552, 552, 81], [552, 552, 81]]
    )
    s = ShapeGenerator.new(3, 4)
    expect(s.scale_noise_table([[324, 628, 198, 98], [882, 901, 336, 552], [81, 479, 290, 70]])).to eq(
      [[901, 901, 336, 336], [901, 901, 336, 336], [479, 479, 290, 290]]
    )
  end

  it "safe_noise_test" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.safe_noise_test(t.testnoisetab, 3, 2)).to eq(70)
    expect(t.testgen.safe_noise_test(t.testnoisetab, 20, 4)).to eq(0)
  end

  it "get_smooth_noise_table" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.get_smooth_noise_table(t.testnoisetab)).to eq([[226, 393, 294], [289, 549, 442], [297, 431, 282], [231, 234, 97]])
  end

  it "shift_and_generate_noise" do
    s = ShapeGenerator.new(4, 3)
    testresult = s.shift_and_generate_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])
    expect(testresult[0...3]).to eq([[98, 882, 901], [336, 552, 81], [479, 290, 70]])
    expect(testresult.length).to eq(4)
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
       [[false, false, false], [false, false, false], [false, false, true], [false, true, true]],
       t.testemptyshape]
    )
  end

  it "cutoff_loose_fragments" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.cutoff_loose_fragments(t.testchunkstab)).to eq(
      [[false, false, false], [false, false, false], [false, false, true], [false, true, true]]
    )
    # empty shape -> empty shape
    expect(t.testgen.cutoff_loose_fragments(t.testemptyshape)).to eq(t.testemptyshape)
  end

  it "render_shape_from_noise" do
    t = ShapeGeneratorTest.new
    expect(t.testgen.render_shape_from_noise(t.testnoisetab)).to eq(
      [[false, true, false], [false, true, true], [false, true, false], [false, false, false]]
    )
  end

  it "shape_from_basenoise" do
    s = ShapeGenerator.new(4, 3)
    expect(s.shape_from_basenoise([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], 1, true)).to eq(
      [[true,true,false],[true,true,true],[false,false,false],[false,false,false]]
    )
    expect(s.shape_from_basenoise([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], 1, false)).to eq(
      [[true,true,false],[true,true,true],[false,false,false],[false,false,false]]
    )
  end

  it "generate_shape" do
    t = ShapeGeneratorTest.new
    t.testgen.generate_shape(1, true).each { |result_tab|
      expect(result_tab.length).to eq(4)
      expect(result_tab.index { |col| col.length != 3 }).to eq(nil)
    }
  end

  it "shift_and_generate" do
    s = ShapeGenerator.new(4, 3)
    shape, basenoise = s.shift_and_generate([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], 1, false)
    expect(shape[0...2]).to eq([[false,false,false],[false,false,false]])
    expect(basenoise[0...3]).to eq([[209,944,801],[108,79,418],[581,486,932]])
  end
end

