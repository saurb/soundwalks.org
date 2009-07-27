# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def first_name user, options = {}
    if logged_in? && user == current_user && !defined? options[:force_third_person]
      "You"
    else
      user.name.split(' ').first
    end
  end
  
  def first_name_verb user, options = {}
    if logged_in? && user == current_user && !defined? options[:force_third_person]
      "are"
    else
      "is"
    end
  end
  
  def first_name_verb_negative user, options = {}
    if logged_in? && user == current_user && !defined? options[:force_third_person]
      "aren't"
    else
      "isn't"
    end
  end
  
  def truncate_words(input, words, symbol)
    inputs = input.split(' ')
    if inputs.size <= words
      return input
    else
      return (0..words - 1).map {|i| inputs[i]}.join(' ') + " #{symbol}"
    end
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
  
  def new_soundwalk_sound_path_with_session_information soundwalk
    session_key = ActionController::Base.session_options[:key]
    new_soundwalk_sound_path(soundwalk, :session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
end
