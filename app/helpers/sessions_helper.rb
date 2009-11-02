module SessionsHelper
  #-------------------------------------#
  # Formats errors that occur at login. #
  #-------------------------------------#
  
  def login_error user, attribute
    user.errors.each do |attr, error|
      if attr.eql? attribute
        return "<span class='error'>#{error}</span>"
      end
    end
  end
end