class ShapeGenerator

  attr_reader :size_x, :size_y, :shape, :debug_info

  # constructor, main loop of shape generation is here
  def initialize(size_x, size_y)
    @size_x = size_x
    @size_y = size_y
  end

  # checks if shape looks good with some "magic" stats limits
  def fail_beauty_stats
    w = weight(@shape)
    s = @size_x * @size_y
    return(w <= 6 or (w >= 7 and w <=12 and s >= 4 * w))
  end

  # returns noise table, that is: 2-dim. array with random numbers between 0 and 1000
  def get_noise_table()
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| rand(1000) }}
  end

  # sets noise table value for x, y in boundaries [0, @size>
  # does nothing for x, y outside of boundaries
  def safe_noise_set(noise, x, y, value)
    if((0...@size_x).include?(x) and (0...@size_y).include?(y)) then noise[x][y] = value end
  end

  # prepare table filled with 0s
  def get_zeros_table()
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| 0 }}
  end

  # table noise -> 2 * noise
  # fitting in table of same size
  # so effectively: 1/4th of 2 * noise
  def scale_noise_table(noise)
    tab = get_zeros_table
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| [0,1].product([0,1]).each {
      |a,b| safe_noise_set(tab, 2 * x + a, 2 * y + b, noise[x][y])
    }}}
    return tab
  end

  # get value noise[x][y] without exception if x, y are out of bounds (0 instead)
  def safe_noise_test(noise, x, y)
    if((0...@size_x).include?(x) and (0...@size_y).include?(y)) then noise[x][y] else 0 end
  end

  # do "smoothing" step on noise table
  # "smoothing" is averaging the values of a position and surrounding positions in the table
  # with weights: center as 1/4, sides (N, E, S, W) as 1/8 each, corners (NE, NW, SE, SW) as 1/16 each
  def get_smooth_noise_table(noise)
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| 
      ([-1,0,1].product([-1,0,1]).inject(0) { |sum, d| sum + safe_noise_test(noise, x + d[0], y + d[1]) / (2 ** (d[0].abs + d[1].abs + 2)) })
    }}
  end

  # get standard-size table filled with false values
  def build_empty_shape
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| false }}
  end

  # get standard-size table filled with nil values
  def build_empty_shape_nil
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| nil }}
  end

  # weight: number of true values in a table
  def weight(shape)
    (shape.flatten.select { |a| a }).length
  end
  
  # find first true value in a shape table
  def find_first_point(shape)
    searchtab = (0...@size_x).collect { |x| shape[x].index {|elem| elem} }
    i = searchtab.index {|elem| elem!=nil}
    if(i) then [i, searchtab[i]] else nil end
  end

  # from_shape - sub_shape
  def substract_shape(from_shape, sub_shape)
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| from_shape[x][y] and not sub_shape[x][y] }}
  end

  # [true/false/nil] table -> [true/false] table
  def denil_chunk(chunk)
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| ![false,nil].include?(chunk[x][y]) }}
  end

  # recursive whole shape extracting
  # curr_chunk - accumulated result shape
  # map_shape - input nil-shape (possibly consisting of many separate whole shapes)
  # x, y - current position of processing
  def get_whole_shape(curr_chunk, map_shape, x, y)
    if((0...@size_x).include?(x) and (0...@size_y).include?(y))
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
      chunk = build_empty_shape_nil()
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
    (0 ... @size_x).collect { |x| (0 ... @size_y).collect { |y| ((noise[x][y]) >= 500) }}
  end

  # generate shape by variation of 2-dimensional Perlin noise
  def generate_shape(iter, cutoff)
    noise = get_noise_table
    iter.times {
      noise = scale_noise_table(noise)
      noise = get_smooth_noise_table(noise)
    }
    shape = render_shape_from_noise(noise)
    @shape = (if cutoff then cutoff_loose_fragments(shape) else shape end)
  end

  # generate the shape until it passes arbitrary stats
  def generate(iter, cutoff)
    begin
      generate_shape(iter, cutoff)
    end while fail_beauty_stats
  end

end
