# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def first_name user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      options[:capitalize] ? "You" : "you"
    else
      user.name.split(' ').first
    end
  end
  
  def first_name_verb user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      "are"
    else
      "is"
    end
  end
  
  def first_name_verb_negative user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      "aren't"
    else
      "isn't"
    end
  end
  
  def first_name_possessive user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      options[:capitalize] ? "Your" : "your"
    else  
      user.name.split(' ').first + "'s"
    end
  end
  
  def new_soundwalk_sound_path_with_session_information soundwalk
    session_key = ActionController::Base.session_options[:key]
    new_soundwalk_sound_path(soundwalk, :session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
end
