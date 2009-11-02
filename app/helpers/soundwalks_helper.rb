module SoundwalksHelper  
  #-------------------------------------------------------------------------------------------#
  # Returns the formatted start/stop times of a list of times from the soundwalk's GPS trace. #
  #-------------------------------------------------------------------------------------------#
  def time_span soundwalk
    return relative_time_span(soundwalk.times.collect {|time| time})
  end
  
  #----------------------------------------------------------------#
  # Returns the formatted start time of the soundwalk's GPS trace. #
  #----------------------------------------------------------------#
  
  def relative_start_date soundwalk
    return relative_date_in_past(soundwalk.locations.first.first)
  end
  
  #------------------------------------------------------------------------------------------#
  # Returns only the formatted date component of the stat time of the soundwalk's GPS trace. #
  #------------------------------------------------------------------------------------------#
  
  def start_date soundwalk
    return soundwalk.locations.first.first.strftime("%Y %b %d")
  end
  
  #-------------------------------------------------------------------------------------------#
  # Returns only the formatted time component of the start time of the soundwalk's GPS trace. #
  #-------------------------------------------------------------------------------------------#
  
  def start_time soundwalk
    return soundwalk.locations.first.first.strftime("%I:%M %p")
  end
  
  #-----------------------------------------------------------------------------------------#
  # Returns only the formatted time component of the end time of the soundwalk's GPS trace. #
  #-----------------------------------------------------------------------------------------#
  
  def end_time soundwalk
    return soundwalk.locations.last.first.strftime("%I:%M %p")
  end
  
  #-------------------------------------------------------------------------------#
  # Returns the formatted time for when the soundwalk was uploaded to the server. #
  #-------------------------------------------------------------------------------#
  
  def post_date soundwalk
    return relative_date_in_past(soundwalk.created_at)
  end
end
