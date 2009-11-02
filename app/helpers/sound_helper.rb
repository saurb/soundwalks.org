require 'gchart'

module SoundHelper
  #-----------------------------------------------#
  # Displays a line chart of an acoustic feature. #
  #-----------------------------------------------#
  
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
  
  #------------------#
  # Marker for maps. #
  #------------------#
  
  def medium_marker_icon
    return GoogleMapIcon.new(:anchor_x => 16, :anchor_y => 16, :width => 32, :height => 32, :shadow_width => 0, :shadow_height => 0, :image_url => '/images/big_marker_75.png')
  end
end

