class ShapeGenerator

  attr_reader :size_x, :size_y, :shape, :debug_info

  def initialize(size_x, size_y, cutoff_lf)
    @size_x = size_x
    @size_y = size_y
    begin
      generate_shape_4(cutoff_lf)
    end while fail_beauty_stats
  end

  def fail_beauty_stats
    w = weight(@shape)
    s = @size_x * @size_y
    return(w <= 6 or (w >= 7 and w <=12 and s >= 4 * w))
  end

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

  def safe_noise_set(noise, x, y, value)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      noise[x][y] = value
    end
  end

  def scale_noise_table(noise)
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

  def safe_noise_test(noise, x, y)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      return noise[x][y]
    else
      return 0
    end
  end

  def get_smooth_noise_table(noise)
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

  # variation of 2-dimensional Perlin noise
  # possible TODOs: elimination of holes, trimming size to fit existing shape
  def generate_shape_4(cutoff_lf)
    @shape = build_empty_shape
    noise = scale_noise_table(get_noise_table())
    noise2 = get_smooth_noise_table(noise)

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

  def random_shape_add(minx = 0, miny = 0, maxx = @size_x - 1, maxy = @size_y - 1)
    rx = rand(maxx - minx + 1) + minx
    ry = rand(maxy - miny + 1) + miny
    @shape[rx][ry] = true
    return rx, ry
  end

  def safe_shape_add(x, y, shape=@shape)
    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      shape[x][y] = true
    end
  end

  def grow_turn
    new_shape = build_empty_shape

    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(@shape[x][y])
          new_shape[x][y] = true
          safe_shape_add(x-1, y, new_shape)
          safe_shape_add(x, y-1, new_shape)
          safe_shape_add(x+1, y, new_shape)
          safe_shape_add(x, y+1, new_shape)
        end
      end
    end

    @shape = new_shape
  end

  def shape_total_area
    ret = 0

    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(@shape[x][y])
          ret += 1
        end
      end
    end

    return ret
  end

  def safe_test_add(x, y, src_shape, trg_shape)
    ret = 0

    if(x >= 0 and y >= 0 and x < @size_x and y < @size_y)
      if(src_shape[x][y] and (not trg_shape[x][y]))
        trg_shape[x][y] = true
        ret = 1
      end
    end

    return ret
  end

  def copy_array(src_shape, trg_shape)
    for x in (0 ... @size_x)
      for y in (0 ... @size_y)
        if(src_shape[x][y])
          trg_shape[x][y] = true
        end
      end
    end
  end

  def test_integrity(startx, starty)
    if(not @shape[startx][starty])
      return nil
    end

    test_shape = build_empty_shape
    test_shape[startx][starty] = true
    test_area = 1
    whole_area = shape_total_area
   
    begin
      added_area = 0
      tmp_shape = build_empty_shape
      copy_array(test_shape, tmp_shape)
      for x in (0 ... @size_x)
        for y in (0 ... @size_y)
          if(tmp_shape[x][y])
            added_area += safe_test_add(x-1, y, @shape, tmp_shape)
            added_area += safe_test_add(x, y-1, @shape, tmp_shape)
            added_area += safe_test_add(x+1, y, @shape, tmp_shape)
            added_area += safe_test_add(x, y+1, @shape, tmp_shape)
          end
        end
      end
      test_area += added_area
      test_shape = tmp_shape
    end while added_area > 0 

    return (test_area == whole_area)
  end

end

