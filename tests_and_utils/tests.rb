require './utils.rb'
require '../core/shape_generator'

def getGenerator
  ShapeGenerator.new
end

RSpec.describe ShapeGenerator do

  it "get_noise_table" do
    s = getGenerator
    testnewnoisetab = s.get_noise_table(4, 3)
    expect(testnewnoisetab.length).to eq(4)
    expect(testnewnoisetab.index { |col| col.length != 3 }).to eq(nil)
    expect(testnewnoisetab.flatten.index { |elem| elem < 0 or elem > 1000 }).to eq(nil)
  end

  it "safe_noise_set" do
    s = getGenerator
    testnoise = [[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]]
    s.safe_noise_set(testnoise, 3, 2, 78)
    expect(testnoise[3][2]).to eq(78)
    s.safe_noise_set(testnoise, 20, 4, 78) # no error -> test passed
  end

  it "get_zeros_table" do
    s = getGenerator
    testnewnoisetab = s.get_zeros_table(4, 3)
    expect(testnewnoisetab.length).to eq(4)
    expect(testnewnoisetab.index { |col| col.length != 3 }).to eq(nil)
    expect(testnewnoisetab.flatten.index { |elem| elem != 0 }).to eq(nil)
  end

  it "add_margin" do
    s = getGenerator
    expect(s.add_margin([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[500, 500, 500, 500, 500], [500, 324, 628, 198, 500], [500, 98, 882, 901, 500], [500, 336, 552, 81, 500], 
       [500, 479, 290, 70, 500], [500, 500, 500, 500, 500]]
    )
  end

  it "cut_margin" do
    s = getGenerator
    expect(s.cut_margin([[500, 500, 500, 500, 500], [500, 324, 628, 198, 500], [500, 98, 882, 901, 500], 
                         [500, 336, 552, 81, 500], [500, 479, 290, 70, 500], [500, 500, 500, 500, 500]])).to eq(
      [[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]]
    )
  end

  it "scale_noise_table" do
    s = getGenerator
    expect(s.scale_noise_table([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[882, 882, 901], [882, 882, 901], [552, 552, 81], [552, 552, 81]]
    )
    s = getGenerator
    expect(s.scale_noise_table([[324, 628, 198, 98], [882, 901, 336, 552], [81, 479, 290, 70]])).to eq(
      [[901, 901, 336, 336], [901, 901, 336, 336], [479, 479, 290, 290]]
    )
  end

  it "safe_noise_test" do
    s = getGenerator
    expect(s.safe_noise_test([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], 3, 2)).to eq(70)
    expect(s.safe_noise_test([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], 20, 4)).to eq(500)
  end

  it "get_smooth_noise_table" do
    s = getGenerator
    expect(s.get_smooth_noise_table([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[443, 517, 511], [413, 549, 566], [421, 431, 406], [448, 358, 314]])
  end

  it "shift_and_generate_noise" do
    s = getGenerator
    testresult = s.shift_and_generate_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], :E)
    expect(testresult[0...3]).to eq([[98, 882, 901], [336, 552, 81], [479, 290, 70]])
    expect(testresult.length).to eq(4)
    testresult = s.shift_and_generate_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], :W)
    expect(testresult[1...4]).to eq([[324, 628, 198], [98, 882, 901], [336, 552, 81]])
    expect(testresult.length).to eq(4)
    testresult = s.shift_and_generate_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], :N)
    expect(testresult.collect { |col| col[1...3] }).to eq([[324, 628], [98, 882], [336, 552], [479, 290]])
    testresult = s.shift_and_generate_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]], :S)
    expect(testresult.collect { |col| col[0...2] }).to eq([[628, 198], [882, 901], [552, 81], [290, 70]])
  end

  it "build_empty_shape_nil" do
    s = getGenerator
    testtab = s.build_empty_shape_nil(4, 3)
    expect(testtab.length).to eq(4)
    expect(testtab.index { |col| col.length != 3 }).to eq(nil)
    expect(testtab.flatten.index { |elem| elem != nil }).to eq(nil)
  end

  it "weight" do
    s = getGenerator
    expect(s.weight([[false, true, true], [true, true, false], [false, true, false], [false, true, false]])).to eq(6)
  end

  it "find_first_point" do
    s = getGenerator
    x, y = s.find_first_point([[false, true, true], [true, true, false], [false, true, false], [false, true, false]])
    expect(([[false, true, true], [true, true, false], [false, true, false], [false, true, false]])[x][y]).to eq(true)
  end

  it "substract_shape" do
    s = getGenerator
    subshapetab = [[false, true, false], [true, false, false], [false, true, false], [false, true, false]]
    expect(s.substract_shape([[false, true, true], [true, true, false], [false, true, false], [false, true, false]], 
      subshapetab)).to eq( 
      [[false, false, true], [false, true, false], [false, false, false], [false, false, false]])
  end

  it "denil_chunk" do
    s = getGenerator
    expect(s.denil_chunk([[nil, true, true], [true, true, false], [false, true, nil], [nil, true, false]])).to eq(
      [[false, true, true], [true, true, false], [false, true, false], [false, true, false]])
  end

  it "divide_into_whole_shapes" do
    s = getGenerator
    expect(s.divide_into_whole_shapes(
      [[false, true, true], [false, false, false], [false, false, true], [false, true, true]])).to eq(
      [[[false, true, true], [false, false, false], [false, false, false], [false, false, false]],
       [[false, false, false], [false, false, false], [false, false, true], [false, true, true]],
       [[false, false, false], [false, false, false], [false, false, false], [false, false, false]]]
    )
  end

  it "cutoff_loose_fragments" do
    s = getGenerator
    expect(s.cutoff_loose_fragments(
    [[false, true, true], [false, false, false], [false, false, true], [false, true, true]])).to eq(
      [[false, false, false], [false, false, false], [false, false, true], [false, true, true]]
    )
    # empty shape -> empty shape
    expect(s.cutoff_loose_fragments(
    [[false, false, false], [false, false, false], [false, false, false], [false, false, false]])).to eq(
    [[false, false, false], [false, false, false], [false, false, false], [false, false, false]])
  end

  it "render_shape_from_noise" do
    s = getGenerator
    expect(s.render_shape_from_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[false, true, false], [false, true, true], [false, true, false], [false, false, false]]
    )
  end

  it "shape_from_basenoise" do
    s = getGenerator
    expect(s.shape_from_basenoise([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], 1, true)).to eq(
      [[true, true, true], [false, false, true], [false, false, true], [false, true, true]]
    )
    expect(s.shape_from_basenoise([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], 1, false)).to eq(
      [[true, true, true], [false, false, true], [false, false, true], [false, true, true]]
    )
  end

  it "generate_shape" do
    s = getGenerator
    s.generate_shape(4, 3, 1, true).each { |result_tab|
      expect(result_tab.length).to eq(4)
      expect(result_tab.index { |col| col.length != 3 }).to eq(nil)
    }
  end

  it "shift_and_generate" do
    s = getGenerator
    shape, basenoise = s.shift_and_generate([[745,183,743],[209,944,801],[108,79,418],[581,486,932]], :E, 1, false)
    expect(shape[0...2]).to eq([[false, false, true], [false, true, true]])
    expect(basenoise[0...3]).to eq([[209,944,801],[108,79,418],[581,486,932]])
  end
end

