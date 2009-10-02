module SoundwalksHelper  
  def time_span soundwalk
    return relative_time_span(soundwalk.times.collect {|time| time})
  end
  
  def relative_start_date soundwalk
    return relative_date_in_past(soundwalk.locations.first.first)
  end
  
  def start_date soundwalk
    return soundwalk.locations.first.first.strftime("%Y %b %d")
  end
  
  def start_time soundwalk
    return soundwalk.locations.first.first.strftime("%I:%M %p")
  end
  
  def end_time soundwalk
    return soundwalk.locations.last.first.strftime("%I:%M %p")
  end
  
  def post_date soundwalk
    return relative_date_in_past(soundwalk.created_at)
  end
  
  def soundwalk_json(soundwalk)
    soundwalk.to_json(
      :include => {
        :formatted_description => textilize(soundwalk.description),
        :formatted_lat => coordinates_text(:latitude, soundwalk.lat),
        :formatted_lng => coordinates_text(:longitude, soundwalk.lng),
      }
    )
  end
end
