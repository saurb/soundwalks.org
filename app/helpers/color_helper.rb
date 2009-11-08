module ColorHelper
  include Math
  
  def xy_to_hsv xy
    sqrt2 = sqrt(2)
    
    x2 = (xy[0] - 0.5) * (2 / sqrt2)
    y2 = (xy[1] - 0.5) * (2 / sqrt2)
    
    a = atan(y2 / x2)
    a_abs = atan(y2.abs / x2.abs)
    l = sqrt(x2 * x2 + y2 * y2)
    
    if x2 >= 0 and y2 >= 0
      h = a / (2 * PI)
    elsif x2 < 0 and y2 >= 0
      h = (a + PI) / (2 * PI)
    elsif x2 < 0 and y2 < 0
      h = (a + PI) / (2 * PI)
    elsif x2 >= 0 and y2 < 0
      h = (a + 2 * PI) / (2 * PI)
    end
    
    if a_abs < PI / 4
      r = 1 / (sqrt2 * cos(a_abs))
    else
      r = 1 / (sqrt2 * sin(a_abs))
    end
    
    if l == 0
      s = 0
    else
      s = l / r
    end
    
    [h * 360, s ** 0.5, 1]
  end
  
  def hsv_to_rgb hsv
    hue_index = (hsv[0] / 60).to_i % 6
    f = (hsv[0] / 60) - (hsv[0] / 60).to_i
    p = hsv[2] * (1 - hsv[1])
    q = hsv[2] * (1 - f * hsv[1])
    t = hsv[2] * (1 - (1 - f) * hsv[1])
    
    if hue_index == 0
      rgb = [hsv[2], t, p]
    elsif hue_index == 1
      rgb = [q, hsv[2], p]
    elsif hue_index == 2
      rgb = [p, hsv[2], t]
    elsif hue_index == 3
      rgb = [p, q, hsv[2]]
    elsif hue_index == 4
      rgb = [t, p, hsv[2]]
    else
      rgb = [hsv[2], p, q]
    end
    
    rgb
  end
end
