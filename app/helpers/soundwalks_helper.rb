module SoundwalksHelper  
  def time_span soundwalk
    return relative_time_span(soundwalk.times.collect {|time| time.getlocal})
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
  
  def stream_item soundwalk, show_users, list_item  
    # Avatar.
		avatar = show_users ? "<div class='update_avatar'>" + link_to(avatar_tag(soundwalk.user, :size => 50), user_name_path(soundwalk.user)) + "</div>" : ""
		
		# Content.
		delete_button = ""
		if logged_in? && current_user.id == soundwalk.user.id
		  delete_button = "<div class='soundwalk_delete'>"
		  delete_button += link_to_remote '<span class="delete_button">X</span> Delete', :method => :delete, :url => soundwalk_url(soundwalk), :before => "cancelProp(event);"
		  delete_button += "</div>"
		end
		
		date = "<div class='soundwalk_meta'>Posted: #{post_date soundwalk}<br />Recorded: #{time_span soundwalk}</div>"
		title = "<span class='soundwalk_title'>"
		title += link_to(soundwalk.user.login, user_name_path(soundwalk.user), :onclick => "cancelProp(event);") + " - " if show_users
		title += link_to(soundwalk.title, soundwalk, :onclick => "cancelProp(event);") + "</span>"
		
		description_text = truncate_words(soundwalk.description, 20, "&hellip;")
    description = "<span class='soundwalk_description'>#{description_text}</span>"
    content = "<div class='update_content'>#{date}#{delete_button}#{title}#{description}</div>"
    
    if list_item
      return "<li id='soundwalk-#{soundwalk.id}' onclick='window.location=\"#{soundwalk_path(soundwalk)}\"'>#{avatar}#{content}</li>"
    else
      return "<div class='map_item'>#{avatar}#{content}</div>"
    end
  end
end
