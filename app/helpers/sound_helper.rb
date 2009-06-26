require 'gchart'

module SoundHelper
  def feature_chart(title, data, max_value, color)
    image_tag Gchart.line(
  		:size => '600x100',
  		:title => title, 
  		:bar_colors => color,
  		:axis_with_labels => 'x,y',
  		:axis_labels => [("0|"+data.length.to_s), '0|1'],
  		:bg => 'FFFFFF00',
  	  :data => data,
  		:max_value => max_value)
  end
end
