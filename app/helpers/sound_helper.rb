require 'gchart'

module SoundHelper
  def feature_chart(title, data, max_value, color)
    image_tag Gchart.line(
  		:size => '600x100',
  		:title => title, 
  		:bar_colors => color,
  		:axis_with_labels => 'x,y',
  		:axis_labels => [("0|" + data.length.to_s), '0|1'],
  		:bg => 'FFFFFF00',
  	  :data => data,
  		:max_value => max_value)
  end
  
  def sound_file_path(sound)
    return 'http://localhost:3000/data/sounds/' + sound.filename
  end
  
  def embed_sound_tag(soundwalk, sound)
    return "<embed 
      type='application/x-shockwave-flash' 
      src='http://www.google.com/reader/ui/3247397568-audio-player.swf?audioUrl=#{soundwalk_sound_url(soundwalk, sound)}.wav' 
      style='width: 400px; height: 27px'
      allowscriptaccess='never' 
      quality='best' 
      bgcolor='#ffffff' 
      wmode='window' 
      flashvars='playerMode=embedded'/>"
  end
  
  def coordinates_text(type, number)
    direction = type == :latitude ? (number < 0 ? 'N' : 'S') : (number < 0 ? 'W' : 'E')
    number = number < 0 ? -number : number
    
    degrees = number.to_i
    remainder = number - degrees;
    
    minutes = (remainder * 60).to_i
    remainder = (remainder * 60) - minutes
    
    seconds = (remainder * 60).to_i
    
    return degrees.to_s + '&deg;' + minutes.to_s + "'" + seconds.to_s + '&quot; ' + direction 
  end
  
  def medium_marker_icon
    return GoogleMapIcon.new(:width => 24, :height => 24, :shadow_width => 0, :shadow_height => 0, :image_url => '/images/medium_marker_75.png')
  end
  
  def filter_feature_values(values)
    for i in 0..values.size - 1
      values[i] = 0 if values[i] > 0 || values[i].nil?
    end
    
    return values
  end
  
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

