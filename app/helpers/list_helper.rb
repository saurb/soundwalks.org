module ListHelper
  def interpolate(values, x)
    if x > values.size - 1
      return values[values.size - 1]
    else
      low = x.floor
      high = low + 1
    
      alpha = 1.0 - (x - low.to_f)
      return alpha * values[low] + (1.0 - alpha) * values[high]
    end
  end

  def limit_granularity(values, max_size = 500)    
    if (values.size > max_size)
      new_values = Array.new(max_size, 0)
    
      for i in 0..max_size - 1
        new_values[i] = interpolate(values, (i.to_f / (max_size - 1).to_f) * values.size.to_f)
      end
    
      return new_values
    else
      return values
    end
  end
end