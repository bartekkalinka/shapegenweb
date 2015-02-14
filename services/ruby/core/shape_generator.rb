class ShapeGenerator

  include Timing

  # returns noise table, that is: 2-dim. array with random numbers between 0 and 1000
  def get_noise_table(size)
    (0 ... size).collect { |x| (0 ... size).collect { |y| rand(1000) }}
  end

  # sets noise table value for x, y in boundaries [0, @size>
  # does nothing for x, y outside of boundaries
  def safe_noise_set(noise, x, y, value)
    if((0...noise.length).include?(x) and (0...noise[0].length).include?(y)) then noise[x][y] = value end
  end

  # prepare table filled with 0s
  def get_zeros_table(size)
    (0 ... size).collect { |x| (0 ... size).collect { |y| 0 }}
  end

  # surround a noise table with zeros
  # size x, y -> size x + 2, y + 2
  def add_margin(noise)
    (0 ... noise.length + 2).collect { |x| (0 ... noise[0].length + 2).collect { |y| safe_noise_test(noise, x - 1, y - 1) }}
  end

  # cut margins
  # size x + 2, y + 2 -> x, y
  def cut_margin(noise)
    (0 ... noise.length - 2).collect { |x| (0 ... noise[0].length - 2).collect { |y| noise[x + 1][y + 1] }}
  end

  # table noise -> 2 * noise
  # fitting in table of same size
  # so effectively: 1/4th of 2 * noise
  def scale_noise_table(noise)
    half_x, half_y = [noise.length, noise[0].length].collect { |a| (a / 2).ceil + (a % 2) - 1 }
    tab = get_zeros_table(noise.length)
    (0 ... 2 * noise.length).collect { |x| (0 ... 2 * noise[0].length).collect { |y| [0,1].product([0,1]).each {
      |a,b| safe_noise_set(tab, 2 * (x - half_x) + a, 2 * (y - half_y) + b, safe_noise_test(noise, x, y))
    }}}
    return tab
  end

  # get value noise[x][y] without exception if x, y are out of bounds (0 instead)
  def safe_noise_test(noise, x, y)
    if((0...noise.length).include?(x) and (0...noise[0].length).include?(y)) then noise[x][y] else 500 end
  end

  # do "smoothing" step on noise table
  # "smoothing" is averaging the values of a position and surrounding positions in the table
  # with weights: center as 1/4, sides (N, E, S, W) as 1/8 each, corners (NE, NW, SE, SW) as 1/16 each
  def get_smooth_noise_table(noise)
    (0 ... noise.length).collect { |x| (0 ... noise[0].length).collect { |y| 
      ([-1,0,1].product([-1,0,1]).inject(0) { |sum, d| sum + safe_noise_test(noise, x + d[0], y + d[1]) / (2 ** (d[0].abs + d[1].abs + 2)) })
    }}
  end

  # weight: number of true values in a table
  def weight(shape)
    (shape.flatten.select { |a| a }).length
  end
  
  # noise table -> shape
  def render_shape_from_noise(noise)
    (0 ... noise.length).collect { |x| (0 ... noise[0].length).collect { |y| ((noise[x][y]) >= 500) }}
  end

  def shape_from_basenoise(basenoise, iter)
    noise = basenoise
    iter.times { |i|
      noise = add_margin(noise)
      noise = scale_noise_table(noise)
      noise = get_smooth_noise_table(noise)
      noise = cut_margin(noise)
    }
    shape = render_shape_from_noise(noise)
  end

  def offset_switch(coord, size)
    if coord >= size then 1 else 0 end
  end

  def offset_trim(coord, size)
    if coord >= size then coord - size else coord end
  end

  # basenoisetab: 2-dimensional array containing 4 square noise tables of same size
  # offset: array with 2 elements - position of left upper corner of result noise table
  def get_shifted_basenoise(basenoisetab, offset)
    size = basenoisetab[0][0].length
    (offset[0]...(size + offset[0])).collect { 
      |x| (offset[1]...(size + offset[1])).collect { 
        |y| basenoisetab[offset_switch(x, size)][offset_switch(y, size)][offset_trim(x, size)][offset_trim(y, size)] 
      }
    }
  end

end
