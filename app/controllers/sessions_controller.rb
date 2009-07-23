# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'user'
  
  # GET /sessions/new, /login
  def new
  end
  
  # POST /sessions
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
    else
      flash.now[:error] = "There were some problems logging into your account. Please review the errors and try again."
      if User.valid_login?(params[:login])
        flash.now[:password_error] = 'incorrect'
      else
        flash.now[:login_error] = "user doesn't exist"
      end
      
      note_failed_signin
      
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  # DELETE /sessions/:id
  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
