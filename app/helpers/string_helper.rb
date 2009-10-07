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
  
  def formatted_sound_tags(sound)
    unique_tag_ids = @sound.tags.collect{|tag| tag.id}.uniq
    results = Link.query_distribution(@sound, {'Tag' => unique_tag_ids})
    
    for i in 0...results.size
      results[i][:deviation] = (results[i][:value] - (1.0 / results.size.to_f)) / (1.0 / results.size.to_f)
    end
    
    return results.collect{|result| "<span style='font-size: #{(1 + result[:deviation]) * 2}em'>#{result[:name]}</span>"}.join(', ')
  end
end