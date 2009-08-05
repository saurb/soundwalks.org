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
  
  def strip_html(str, preserve_tags = ['a', 'img', 'p', 'br', 'i', 'b', 'u', 'ul', 'li'])
    str = str.strip || ''
    preserve_array = preserve_tags.join('|') << '|\/'
    str.gsub(/<(\/|\s)*[^(#{preserve_array})][^>]*>/,'')
  end
end