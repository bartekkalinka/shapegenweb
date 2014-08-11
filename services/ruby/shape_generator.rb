class ShapeGenerator

  attr_reader :size_x, :size_y, :shape, :debug_info

  # constructor, main loop of shape generation is here
  def initialize(size_x, size_y, cutoff_lf)
    @size_x = size_x
    @size_y = size_y
    begin
      generate_shape_4(cutoff_lf)
    end while fail_beauty_stats
  end

  # checks if shape looks good with some "magic" stats limits
  def fail_beauty_stats
    w = weight(@shape)
    s = @size_x * @size_y
    return(w <= 6 or (w >= 7 and w <=12 and s >= 4 * w))
  end

  # returns noise table, that is: 2-dim. array with random numbers between 0 and 1000
  def get_noise_table()
    tab = []

    for x in (0 ... @size_x)
      tab[x] = []
      for y in (0 ... @size_y)
        tab[x][y] = rand(1000)
      end
    end

    return tab
  end

  # sets noise table value for x, y in boundaries [0, @size>
  # does nothing for x, y outside of boundaries
  def safe_noise_set(noise, x, y, value)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      noise[x][y] = value
    end
  end

  # table noise -> 2 * noise
  # fitting in table of same size
  # so effectively: 1/4th of 2 * noise
  def scale_noise_table(noise)

    # prepare table filled with 0s
    tab = []
    for x in (0 ... @size_x)
      tab[x] = []
      for y in (0 ... @size_y)
        tab[x][y] = 0
      end
    end

    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        safe_noise_set(tab, 2 * x, 2 * y, noise[x][y])
        safe_noise_set(tab, 2 * x + 1, 2 * y, noise[x][y])
        safe_noise_set(tab, 2 * x, 2 * y + 1, noise[x][y])
        safe_noise_set(tab, 2 * x + 1, 2 * y + 1, noise[x][y])
      end
    end

    return tab
  end

  # get value noise[x][y] without exception if x, y are out of bounds (0 instead)
  def safe_noise_test(noise, x, y)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      return noise[x][y]
    else
      return 0
    end
  end

  # do "smoothing" step on noise table
  # "smoothing" is averaging the values of a position and surrounding positions in the table
  # with weights: center as 1/4, sides (N, E, S, W) as 1/8 each, corners (NE, NW, SE, SW) as 1/16 each
  def get_smooth_noise_table(noise)

    # prepare table filled with 0s
    # TODO duplication with scale_noise_table
    smooth = []
    for x in (0 ... @size_x)
      smooth[x] = []
      for y in (0 ... @size_y)
        smooth[x][y] = 0
      end
    end

    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        corners = ( safe_noise_test(noise, x-1, y-1)+safe_noise_test(noise, x+1, y-1)+safe_noise_test(noise, x-1, y+1)+safe_noise_test(noise, x+1, y+1) ) / 16
        sides   = ( safe_noise_test(noise, x-1, y)  +safe_noise_test(noise, x+1, y)  +safe_noise_test(noise, x, y-1)  +safe_noise_test(noise, x, y+1) ) /  8
        center  = safe_noise_test(noise, x, y) / 4
        smooth[x][y] = (corners + sides + center).floor
      end
    end

    return smooth
  end

  # get standard-size table filled with false values
  def build_empty_shape
    shape = []

    for x in (0 ... @size_x)
      shape[x] = []
      for y in (0 ... @size_y)
        shape[x][y] = false
      end
    end

    return shape
  end

  # get standard-size table filled with nil values
  def build_empty_shape_nil
    shape = []

    for x in (0 ... @size_x)
      shape[x] = []
      for y in (0 ... @size_y)
        shape[x][y] = nil
      end
    end

    return shape
  end

  # weight: number of true values in a table
  def weight(shape)
    ret = 0

    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(shape[x][y])
          ret += 1
        end
      end
    end
    
    return ret
  end
  
  # find first true value in a shape table
  def find_first_point(shape)
    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(shape[x][y])
          return x, y
        end
      end
    end
    return nil
  end

  # from_shape - sub_shape
  def substract_shape(from_shape, sub_shape)
    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(from_shape[x][y] and sub_shape[x][y])
          from_shape[x][y] = false
        end
      end
    end
    return from_shape
  end

  # [true/false/nil] table -> [true/false] table
  def denil_chunk(chunk)
   denil = build_empty_shape
   for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(chunk[x][y])
          denil[x][y] = true
        end
      end
    end
    return denil
  end

  # recursive whole shape extracting
  # curr_chunk - accumulated result shape
  # map_shape - input nil-shape (possibly consisting of many separate whole shapes)
  # x, y - current position of processing
  def get_whole_shape(curr_chunk, map_shape, x, y)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      if(curr_chunk[x][y] != nil)
        return
      end
      curr_chunk[x][y] = false
      if(map_shape[x][y])
        curr_chunk[x][y] = true
        get_whole_shape(curr_chunk, map_shape, x - 1, y - 1)
        get_whole_shape(curr_chunk, map_shape, x - 1, y)
        get_whole_shape(curr_chunk, map_shape, x - 1, y + 1)
        get_whole_shape(curr_chunk, map_shape, x , y - 1)
        get_whole_shape(curr_chunk, map_shape, x , y + 1)
        get_whole_shape(curr_chunk, map_shape, x + 1, y - 1)
        get_whole_shape(curr_chunk, map_shape, x + 1, y)
        get_whole_shape(curr_chunk, map_shape, x + 1, y + 1)
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
    return chunks
  end

  # get one whole shape from input shape
  # by 1. dividing it into whole shapes
  # 2. choosing the largest whole shape as a result
  # TODO better code (no loop, use of some higher-order function)
  def cutoff_loose_fragments(shape)
    chunks = divide_into_whole_shapes(shape)
    max_weight = 0
    max_chunk = shape
    chunks.each { |chunk|
      ch_weight = weight(chunk)
      if(ch_weight > max_weight)
        max_chunk = chunk
        max_weight = ch_weight
      end
    }
    return max_chunk
  end

  # generate shape by variation of 2-dimensional Perlin noise
  # possible TODOs: elimination of holes, trimming size to fit existing shape
  def generate_shape_4(cutoff_lf)
    @shape = build_empty_shape
    noise = scale_noise_table(get_noise_table())
    noise2 = get_smooth_noise_table(noise)

    # noise table -> shape
    # TODO transfer to utility module/class
    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        draw_xy = noise2[x][y]
        if(draw_xy >= 500)
          @shape[x][y] = true
        end
      end
    end

    if(cutoff_lf)
      @shape = cutoff_loose_fragments(@shape)
    end
  end

end
