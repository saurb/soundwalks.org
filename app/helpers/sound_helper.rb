require 'gchart'

module SoundHelper
  def feature_chart(title, data, color)
    image_tag Gchart.line(
  		:size => '400x75',
  		:title => title, 
  		:bar_colors => color,
  		:axis_with_labels => 'x,y',
  		:axis_labels => [("0|" + data.length.to_s), '0|1'],
  		:bg => 'FFFFFF00',
  	  :data => data,
  		:max_value => 1.0)
  end
  
  def sound_file_path(sound)
    return 'http://localhost:3000/data/sounds/' + sound.filename
  end
  
  def medium_marker_icon
    return GoogleMapIcon.new(:anchor_x => 16, :anchor_y => 16, :width => 32, :height => 32, :shadow_width => 0, :shadow_height => 0, :image_url => '/images/big_marker_75.png')
  end
  
  def filter_feature_values(values)
    for i in 0..values.size - 1
      values[i] = 0 if values[i] > 0 || values[i].nil?
    end
    
    return values
  end
end

