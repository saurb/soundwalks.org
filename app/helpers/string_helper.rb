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
  
  def formatted_sound_tags(sound, style)
    all_tags = Tag.find(:all)
    unique_tag_ids = all_tags.collect{|tag| tag.id}.uniq
    
    #unique_tag_ids = @sound.tags.collect{|tag| tag.id}.uniq
    temp_results = Link.query_distribution(@sound, {'Tag' => unique_tag_ids})
    
    results = []
    temp_results = temp_results.sort {|x, y| x[:value] <=> y[:value]}.reverse
    total = 0
    
    temp_results.each do |result|
      total += result[:value]
      results.push result if total < 0.99
    end
    
    for i in 0...results.size
      results[i][:deviation] = (results[i][:value] - (1.0 / results.size.to_f)) / (1.0 / results.size.to_f)
      
      n = MdsNode.find(:first, :conditions => {:owner_id => results[i][:id], :owner_type => 'Tag'})
      
      x = (n.x) * 0.615
      y = (n.y) * 0.436
      c = yuv_to_rgb(0.5, x, y)
      
      results[i][:r] = (c[0] * 255).to_i
      results[i][:g] = (c[1] * 255).to_i
      results[i][:b] = (c[2] * 255).to_i
    end
    
    html = ''
    
    if style == :normal || style == nil
      html += results.collect{|result| "<span style='color: rgb(#{result[:r]}, #{result[:g]}, #{result[:b]}); font-size: #{(1.5 + result[:deviation] * 0.25)}em'>#{result[:name]}</span>"}.join(',')
    elsif style == :old
      html_results = []
      results.each do |result|
        color = "#%02x%02x%02x" % [result[:r], result[:g], result[:b]].map {|i| i}
        html_results.push "<font color='#{color}' size='#{(1.5 + result[:deviation] * 0.25)}em'>#{result[:name]}</font>"
      end
      
      html = html_results.join(',')
    end
    
    html
  end
  
  def yuv_to_rgb y, u, v
    wr = 0.299
    wb = 0.114
    wg = 1 - wr - wb
    umax = 0.436
    vmax = 0.615
    
    r = y + v * ((1 - wr) / vmax)
    g = y - u * ((wb * (1 - wb)) / (umax * wg)) - v * ((wr * (1 - wr)) / (vmax * wg))
    b = y + u * ((1 - wb) / umax)
    
    [r, g, b]
  end
end