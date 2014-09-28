class ShapeGenerator

  include Timing

  # returns noise table, that is: 2-dim. array with random numbers between 0 and 1000
  def get_noise_table(size_x, size_y)
    (0 ... size_x).collect { |x| (0 ... size_y).collect { |y| rand(1000) }}
  end

  # sets noise table value for x, y in boundaries [0, @size>
  # does nothing for x, y outside of boundaries
  def safe_noise_set(noise, x, y, value)
    if((0...noise.length).include?(x) and (0...noise[0].length).include?(y)) then noise[x][y] = value end
  end

  # prepare table filled with 0s
  def get_zeros_table(size_x, size_y)
    (0 ... size_x).collect { |x| (0 ... size_y).collect { |y| 0 }}
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
    tab = get_zeros_table(noise.length, noise[0].length) # TODO less of this: noise.length, noise[0].length
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

  def shift_and_generate_noise(noise, direction)
    case direction
    when :E
      return noise[1...noise.length] + [noise[0].collect { |col| rand(1000) }]
    when :W
      return [noise[0].collect { |col| rand(1000) }] + noise[0...noise.length-1]
    when :N
      return (noise.collect { |col| [rand(1000)] + col[0...noise[0].length-1]})
    when :S
      return (noise.collect { |col| col[1...noise[0].length] + [rand(1000)]})
    end
  end

  # get standard-size table filled with nil values
  def build_empty_shape_nil(size_x, size_y)
    (0 ... size_x).collect { |x| (0 ... size_y).collect { |y| nil }}
  end

  # weight: number of true values in a table
  def weight(shape)
    (shape.flatten.select { |a| a }).length
  end
  
  # find first true value in a shape table
  def find_first_point(shape)
    searchtab = (0...shape.length).collect { |x| shape[x].index {|elem| elem} }
    i = searchtab.index {|elem| elem!=nil}
    if(i) then [i, searchtab[i]] else nil end
  end

  # from_shape - sub_shape
  def substract_shape(from_shape, sub_shape)
    (0 ... from_shape.length).collect { |x| (0 ... from_shape[0].length).collect { |y| from_shape[x][y] and not sub_shape[x][y] }}
  end

  # [true/false/nil] table -> [true/false] table
  def denil_chunk(chunk)
    (0 ... chunk.length).collect { |x| (0 ... chunk[0].length).collect { |y| ![false,nil].include?(chunk[x][y]) }}
  end

  # recursive whole shape extracting
  # curr_chunk - accumulated result shape
  # map_shape - input nil-shape (possibly consisting of many separate whole shapes)
  # x, y - current position of processing
  def get_whole_shape(curr_chunk, map_shape, x, y)
    if((0...curr_chunk.length).include?(x) and (0...curr_chunk[0].length).include?(y))
      if(curr_chunk[x][y] == nil)
        if(curr_chunk[x][y] = map_shape[x][y])
          [-1,0,1].product([-1,0,1]).each { |d| get_whole_shape(curr_chunk, map_shape, x + d[0], y + d[1]) }
        end
      end
    end
  end

  # divide shape
  # into whole shapes it consists of
  # return a list of whole shapes
  def divide_into_whole_shapes(shape)
    left_over = shape
    chunks = []
    while(weight(left_over) > 0)
      x, y = find_first_point(left_over)
      chunk = build_empty_shape_nil(shape.length, shape[0].length)
      get_whole_shape(chunk, left_over, x, y)
      chunks << denil_chunk(chunk)
      left_over = substract_shape(left_over, chunk)
    end
    return chunks + [left_over]
  end

  # get one whole shape from input shape
  # by 1. dividing it into whole shapes
  # 2. choosing the largest whole shape as a result
  def cutoff_loose_fragments(shape)
    divide_into_whole_shapes(shape).max_by { |chunk| weight(chunk) }
  end

  # noise table -> shape
  def render_shape_from_noise(noise)
    (0 ... noise.length).collect { |x| (0 ... noise[0].length).collect { |y| ((noise[x][y]) >= 500) }}
  end

  def shape_from_basenoise(basenoise, iter, cutoff)
    noise = basenoise
    iter.times { |i|
      noise = add_margin(noise)
      noise = scale_noise_table(noise)
      noise = get_smooth_noise_table(noise)
      noise = cut_margin(noise)
    }
    shape = render_shape_from_noise(noise)
    shape = (if cutoff then cutoff_loose_fragments(shape) else shape end)
  end

  def generate_shape(size_x, size_y, iter, cutoff)
    basenoise = get_noise_table(size_x, size_y)
    shape = shape_from_basenoise(basenoise, iter, cutoff)
    return shape, basenoise
  end

  def shift_and_generate(basenoise, direction, iter, cutoff)
    log_timing("generator before")
    basenoise = shift_and_generate_noise(basenoise, direction)
    log_timing("generator shift_and_generate_noise")
    shape = shape_from_basenoise(basenoise, iter, cutoff)
    log_timing("generator shape_from_basenoise")
    return shape, basenoise
  end

end
