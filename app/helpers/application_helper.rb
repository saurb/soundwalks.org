# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #-----------------------------------------------------------#
  # Displays a user's first name, possibly replaced by "you." #
  #-----------------------------------------------------------#
  
  def first_name user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      options[:capitalize] ? "You" : "you"
    else
      user.name.split(' ').first
    end
  end
  
  #-----------------------------------#
  # Displays a "is"/"are" for a user. #
  #-----------------------------------#
  
  def first_name_verb user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      "are"
    else
      "is"
    end
  end
  
  #-----------------------------------------#
  # Displays a "isn't"/"aren't" for a user. #
  #-----------------------------------------#
  
  def first_name_verb_negative user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      "aren't"
    else
      "isn't"
    end
  end
  
  #----------------------------------------#
  # Displays a "your"/"name's" for a user. #
  #----------------------------------------#
  
  def first_name_possessive user, options = {}
    if logged_in? && user.id == current_user.id && !options[:force_third_person]
      options[:capitalize] ? "Your" : "your"
    else  
      user.name.split(' ').first + "'s"
    end
  end
  
  #--------------------------------------------------------------------------#
  # Path to create a new soundwalk, with the session information in the URL. #
  #--------------------------------------------------------------------------#
  
  def new_soundwalk_sound_path_with_session_information soundwalk
    session_key = ActionController::Base.session_options[:key]
    new_soundwalk_sound_path(soundwalk, :session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
end
