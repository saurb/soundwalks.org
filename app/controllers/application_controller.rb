# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  before_filter :login_required, :except => [:new, :create]
  filter_parameter_logging :password
  
  def login_required
    if session[:user]
      return true
    else  
      flash[:warning] = 'Please login to continue'
      session[:return_to] = request.request_uri
      redirect_to :controller => "user", :action => "login"
      
      return false 
    end
  end

  def current_user
    session[:user]
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to] = nil
      redirect_to_url(return_to)
    else
      redirect_to :controller => 'user', :action => 'welcome'
    end
  end
  
end
