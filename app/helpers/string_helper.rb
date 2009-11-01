module StringHelper
  def coordinates_text(type, number)
    direction = type == :latitude ? (number < 0 ? 'N' : 'S') : (number < 0 ? 'W' : 'E')
    number = number < 0 ? -number : number
  
    degrees = number.to_i
    remainder = number - degrees;
  
    minutes = (remainder * 60).to_i
    remainder = (remainder * 60) - minutes
  
    seconds = sprintf('%.2f', remainder * 60)
  
    return degrees.to_s + '&deg;' + minutes.to_s + "'" + seconds.to_s + '&quot; ' + direction 
  end
  
  def truncate_words(input, words, symbol)
    inputs = input.split(' ')
    if inputs.size <= words
      return input
    else
      return (0..words - 1).map {|i| inputs[i]}.join(' ') + " #{symbol}"
    end
  end
  
  def truncate_characters(input, characters, symbol)
    if input.size <= characters
      return input
    else
      return input[0...140] + " #{symbol}"
    end
  end
  
  def strip_html(str, preserve_tags = ['a', 'img', 'p', 'br', 'i', 'b', 'u', 'ul', 'li'])
    str = str.strip || ''
    preserve_array = preserve_tags.join('|') << '|\/'
    str.gsub(/<(\/|\s)*[^(#{preserve_array})][^>]*>/,'')
  end
  
  def formatted_sound_tags(sound, style = nil)
    tags = Tag.find(:all)
    tag_ids = tags.collect{|tag| tag.id}
    tag_names = tags.collect{|tag| tag.name}
    
    nodes = MdsNode.find(:all, :conditions => {:owner_id => tag_ids, :owner_type => 'Tag'})
    node_ids = nodes.collect{|node| node.id}
    
    results = []
    temp_results = Link.query_distribution(@sound.mds_node, nodes.collect {|node| node.id})
    
    if temp_results.size > 0
      temp_results = temp_results.sort {|x, y| x[:value] <=> y[:value]}.reverse
      
      total = 0
      
      temp_results.each do |result|
        total += result[:value]
        results.push result if total < 0.8
      end
    
      for i in 0...results.size
        node_index = node_ids.index(results[i][:id])
        tag_index = tag_ids.index(nodes[node_index].owner_id)
      
        results[i][:deviation] = (results[i][:value] - (1.0 / results.size.to_f)) / (1.0 / results.size.to_f)
        results[i][:name] = tag_names[tag_index]
            
        u = nodes[node_index] == nil ? 0 : nodes[node_index].x * 0.436
        v = nodes[node_index] == nil ? 0 : nodes[node_index].y * 0.615
        c = yuv_to_rgb(0.5, u, v)
      
        results[i][:r] = (c[:r] * 255).to_i
        results[i][:g] = (c[:g] * 255).to_i
        results[i][:b] = (c[:b] * 255).to_i
      end
    
      html = ''
    
      if style == :normal || style == nil
        html += results.collect{|result| "<span style='color: rgb(#{result[:r]}, #{result[:g]}, #{result[:b]}); font-size: #{(1.5 + result[:deviation] * 0.25)}em'>#{result[:name]}</span>"}.join(' ')
      elsif style == :old
        html_results = []
        results.each do |result|
          color = "#%02x%02x%02x" % [result[:r], result[:g], result[:b]].map {|i| i}
          html_results.push "<font color='#{color}' size='#{((1.5 + result[:deviation] * 0.25) * 12).to_i}'>#{result[:name]}</font>"
        end
      
        html = html_results.join(' ')
      end
    
      html
    else
      "This sound does not yet have any tags."
    end
  end
  
  def yuv_to_rgb y, u, v
    r = y + 1.13983 * v
    g = y - 0.39465 * u - 0.58060 * v
    b = y + 2.03211 * u
    
    {:r => r, :g => g, :b => b}
  end
end