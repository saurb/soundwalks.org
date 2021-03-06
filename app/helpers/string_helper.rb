module StringHelper
  #------------------------------------------#
  # Formats latitutde/longitude coordinates. #
  #------------------------------------------#
  
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
  
  #---------------------------------------------------------------------------------#
  # Truncates a string to N words, proceeded by an optional symbol (e.g. ellipses). #
  #---------------------------------------------------------------------------------#
  
  def truncate_words(input, words, symbol)
    inputs = input.split(' ')
    if inputs.size <= words
      return input
    else
      return (0..words - 1).map {|i| inputs[i]}.join(' ') + " #{symbol}"
    end
  end
  
  #--------------------------------------------------------------------------------------#
  # Truncates a string to N characters, proceeded by an optional symbol (e.g. ellipses). #
  #--------------------------------------------------------------------------------------#
  
  def truncate_characters(input, characters, symbol)
    if input.size <= characters
      return input
    else
      return input[0...140] + " #{symbol}"
    end
  end
  
  #--------------------------------------------------------------------------------------------#
  # Strips HTML from user form input to prevent poorly-formed markup from messing up the site. #
  #--------------------------------------------------------------------------------------------#
  
  def strip_html(str, preserve_tags = ['a', 'img', 'p', 'br', 'i', 'b', 'u', 'ul', 'li'])
    str = str.strip || ''
    preserve_array = preserve_tags.join('|') << '|\/'
    str.gsub(/<(\/|\s)*[^(#{preserve_array})][^>]*>/,'')
  end
  
  def formatted_tag_cloud(limit = 200)
    tags = Tag.find(:all)
    
    counts = {}
    tags.each do |tag|
      counts[tag.id] =Tagging.count(:conditions => {:tag_id => tag.id})
    end
    
    tags = tags.sort{|x, y| counts[y.id] <=> counts[x.id]}
    tags = tags[0...limit]
    
    tags1 = []
    tags2 = []
    
    for i in 0...tags.size
      if i % 2 == 0
        tags1.push tags[i]
      else
        tags2.push tags[i]
      end
    end
    
    tags = tags1.reverse.concat tags2
    
    total_count = 0
    
    tags.each do |tag|
      total_count += counts[tag.id]
    end
    
    nodes = MdsNode.find(:all, :conditions => {:owner_type => 'Tag'});
    node_ids = nodes.collect{|node| node.owner_id}
    
    strings = []
    
    tags.each do |tag|
      index = node_ids.index(tag.id)
      
      if index
        color = nodes[index].color
      
        r = (color[0] * 255).to_i
        g = (color[1] * 255).to_i
        b = (color[2] * 255).to_i
      
        deviation = ((counts[tag.id] / total_count.to_f) - (1 / tags.size.to_f)) / (1 / tags.size.to_f)
      
        strings.push "<span style='color: rgb(#{r}, #{g}, #{b}); font-size: #{(1.5 + deviation * 0.25)}em'>#{tag}</span>"
      end
    end
    
    strings.join(' ')
  end
  
  #----------------------------------------------------------------------------------------#
  # Creates a colored tag cloud for a given sound based on its distribution over all tags. #
  #----------------------------------------------------------------------------------------#
  
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
      
      results1 = []
      results2 = []
      
      for i in 0...results.size
        if i % 2 == 0
          results1.push results[i]
        else
          results2.push results[i]
        end
      end
      
      results = results1.reverse.concat results2
      
      for i in 0...results.size
        node_index = node_ids.index(results[i][:id])
        
        if node_index
          tag_index = tag_ids.index(nodes[node_index].owner_id)
          
          results[i][:deviation] = (results[i][:value] - (1.0 / results.size.to_f)) / (1.0 / results.size.to_f)
          results[i][:name] = tag_names[tag_index]
          
          color = nodes[node_index].color
          
          results[i][:r] = (color[0] * 255).to_i
          results[i][:g] = (color[1] * 255).to_i
          results[i][:b] = (color[2] * 255).to_i
        end
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
end