require './utils.rb'
require '../core/shape_generator'

def getGenerator
  ShapeGenerator.new
end

RSpec.describe ShapeGenerator do

  it "get_noise_table" do
    s = getGenerator
    testnewnoisetab = s.get_noise_table(3)
    expect(testnewnoisetab.length).to eq(3)
    expect(testnewnoisetab.index { |col| col.length != 3 }).to eq(nil)
    expect(testnewnoisetab.flatten.index { |elem| elem < 0 or elem > 1000 }).to eq(nil)
  end

  it "safe_noise_set" do
    s = getGenerator
    testnoise = [[324, 628, 198], [98, 882, 901], [336, 552, 81]]
    s.safe_noise_set(testnoise, 2, 2, 78)
    expect(testnoise[2][2]).to eq(78)
    s.safe_noise_set(testnoise, 20, 4, 78) # no error -> test passed
  end

  it "get_zeros_table" do
    s = getGenerator
    testnewnoisetab = s.get_zeros_table(3)
    expect(testnewnoisetab.length).to eq(3)
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
    expect(s.scale_noise_table([[324, 628, 198, 98], [882, 901, 336, 552], [81, 479, 290, 70], [23, 625, 220, 501]])).to eq(
      [[901, 901, 336, 336], [901, 901, 336, 336], [479, 479, 290, 290], [479, 479, 290, 290]]
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

  it "weight" do
    s = getGenerator
    expect(s.weight([[false, true, true], [true, true, false], [false, true, false], [false, true, false]])).to eq(6)
  end

  it "render_shape_from_noise" do
    s = getGenerator
    expect(s.render_shape_from_noise([[324, 628, 198], [98, 882, 901], [336, 552, 81], [479, 290, 70]])).to eq(
      [[false, true, false], [false, true, true], [false, true, false], [false, false, false]]
    )
  end

  it "shape_from_basenoise" do
    s = getGenerator
    expect(s.shape_from_basenoise([[745,183,743,25],[209,944,801,151],[108,79,418,36],[581,486,932,910]], 1)).to eq(
      [[true, true, true, false], [false, false, false, false], [false, false, false, false], [false, true, true, true]]
    )
  end

  it "get_shifted_basenoise" do
    s = getGenerator
    expect(s.get_shifted_basenoise(
      [[[[523, 623], [74, 992]], [[611, 55], [142, 146]]], [[[234, 622], [517, 225]], [[61, 723], [534, 63]]]],
      [1, 2]
    )).to eq(
      [[142, 146], [61, 723]]
    )
  end
end

