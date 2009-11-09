class UsersController < ApplicationController  
  layout 'user', :except => [:edit, :update, :show]
  
  before_filter :login_required, :only => [:settings, :suspend, :unsuspend, :destroy, :purge]
  before_filter :get_user, :except => [:create, :activate, :settings]
  
  #---------------------------#
  # GET /users/new            #
  # GET /signup               #
  #   Shows the sign up form. #
  #---------------------------#
  
  def new
    @user = User.new
  end
  
  #-------------------------------------------------------------------------#
  # POST /users/new                                                         #
  #   Signs up a user given posted (form) data. Sends the activation email. #
  #   TEMPORARY: User must provide the hard-coded secret phrase below.      #
  #   TODO: Make secret phrase a Setting.                                   #
  #-------------------------------------------------------------------------#
  
  def create
    if params[:user]['secret'] != '52521082'
      @user = User.new(params[:user])
      flash.now[:error] = "Incorrect secret phrase."
      render :action => 'new'
    else
      logout_keeping_session!
      @user = User.new(params[:user])
      @user.admin = false
      @user.can_upload = true
      @user.register! if @user && @user.valid?
      success = @user && @user.valid?
      if success && @user.errors.empty?
        flash[:notice] = "Thanks for signing up!  We're sending you an email with a link to activate your account. In the mean time, feel free to explore all the publicly available soundwalks."
        redirect_back_or_default('/')
      else
        flash.now[:error]  = "There were some problems making your account. Please review any errors and try again."
        render :action => 'new'
      end
    end
  end
  
  #-------------------------------------------------------------------#
  # GET /users/activate/:activation_code                              #
  #   Activates a user after they have received the activation email. #
  #-------------------------------------------------------------------#
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  #-------------------------------------------#
  # PUT /users/:id/suspend                    #
  #   Suspends a user's account.              #
  #   User must be logged in and be an admin. #
  #-------------------------------------------#
  
  def suspend
    if current_user.admin?
      @user.suspend! 
      redirect_to users_path
    else
      flash[:error] = "You do not have privileges to suspend this account."
      redirect_back_or_default '/'
    end
  end
  
  #-------------------------------------------#
  # PUT /users/:id/unsuspend                  #
  #   Unsuspends a user's account.            #
  #   User must be logged in and be an admin. #
  #-------------------------------------------#
  
  def unsuspend
    if current_user.admin?
      @user.unsuspend!
      redirect_to users_path
    else
      flash[:error] = "You do not have privileges to unsuspend this account."
      redirect_back_or_default '/'
    end
  end
  
  #-------------------------------------------#
  # DELETE /users/:id                         #
  #   Deletes a user's account.               #
  #   User must be logged in and be an admin. #
  #-------------------------------------------#
  
  def destroy
    if current_user.admin?
      @user.delete!
      redirect_to users_path
    else
      flash[:error] = "You do not have privileges to delete this account."
      redirect_back_or_default '/'
    end
  end
  
  #------------------------------------------------------------#
  # DELETE /users/:id/purge                                    #
  #   Deletes a user's account without deleting owned content. #
  #   User must be logged in and be an admin.                  #
  #------------------------------------------------------------#
  
  def purge
    @user.destroy
    redirect_to users_path
  end
  
  #-------------------------------------------------------------------#
  # GET /users/:id                                                    #
  # GET /:login                                                       #
  #   Shows a user's account, including all their visible soundwalks. #
  #-------------------------------------------------------------------#
  
  def show
    get_soundwalks_from_user
    
    respond_to do |format|
      format.html {render :layout => 'site'}
      format.xml {render :xml => @user.to_xml(user_options)}
      format.json {render :json => @user.to_json(user_options), :callback => params[:callback]}
    end
  end
  
  #------------------------------------#
  # GET /settings                      #
  #   Redirects to GET /users/:id/edit #
  #------------------------------------#
  
  def settings
    redirect_to edit_user_path(current_user)
  end
  
  #------------------------------------------------------#
  # GET /users/:id/edit                                  #
  #   Shows an HTML form to edit a user's account.       #
  #   User must be logged in as the user or be an admin. #
  #------------------------------------------------------#
  
  def edit
    if current_user.id != @user.id && !@user.admin
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      render :layout => 'site'
    end
  end
  
  #-----------------------------------------------------------------#
  # POST /users/:id/edit                                            #
  #   Updates a user's account information with posted (form) data. #
  #   User must be logged in as the user or be an admin.            #
  #-----------------------------------------------------------------#
  
  def update
    if current_user.id != @user.id && !@user.admin
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      success = true
      
      if params[:new_password] && params[:new_password] != '' && !@user.admin
        if User.authenticate(@user.login, params[:old_password])
          params[:user][:password] = params[:new_password]
        else
          success = false
          flash.now[:error] = "Incorrect old password."
          render :layout => 'site', :action => 'edit'
        end
      end
      
      if success
        respond_to do |format|
          if @user.update_attributes(params[:user])
            format.html {
              flash.now[:notice] = "Your profile has been updated."
              render :layout => 'site', :action => "edit"
            }
            format.xml {render :xml => @user.to_xml(user_options), :status => :ok}
            format.json {render :json => @user.to_json(user_options), :status => :ok, :callback => params[:callback]}
          else
            format.html {render :layout => 'site', :action => "edit"}
            format.xml {render :xml => @user.errors, :status => :unprocessable_entity}
            format.json {render :json => @user.errors, :status => :unprocessable_entity, :callback => params[:callback]}
          end
        end
      end
    end
  end
  
  #------------------------------------------------------#
  # GET /:login/followers                                #
  #   Shows a list of people who are following the user. #
  #------------------------------------------------------#
  
  def followers
    render :layout => 'site'
  end
  
  #-----------------------------------------------------#
  # GET /:login/following                               #
  #   Shows a list of people who the user is following. #
  #-----------------------------------------------------#
  
  def following
    render :layout => 'site'
  end
  
protected
  #--------------------------------#
  # Fetches a user by id or login. #
  #--------------------------------#
  
  def get_user
    if params[:id]
      @user = User.find(params[:id])
    elsif params[:login]
      @user = User.find(:first, :conditions => {:login => params[:login]})
      
      if !@user
        flash[:error] = "User &quot;#{params[:login]}&quot; could not be found."
        redirect_back_or_default '/'
      end
    end
  end
  
  #------------------------------------------------------------------------------------------#
  # Gets all visible soundwalks by the user.                                                 #
  #   Either the soundwalks must be public, the logged-in user must own the soundwalks, or   #
  #   the logged-in user must be followed by the user who owns the soundwalks, which must be #
  #   friends-only.                                                                          #
  #------------------------------------------------------------------------------------------#
  
  def get_soundwalks_from_user
    friendships = nil
    friendships = @user.friendships.find(:all, :conditions => "friend_id=#{current_user.id}") if logged_in?
    
    if logged_in? && @user.id == current_user.id
      @soundwalks = @user.soundwalks.find(:all)
    elsif logged_in? && friendships != nil && friendships.size > 0
      @soundwalks = @user.soundwalks.find(:all, :conditions => {:privacy => ['friends', 'public']})
    else
      @soundwalks = @user.soundwalks.find(:all, :conditions => {:privacy => 'public'})
    end
  end
  
  #------------------------------------------------#
  # Options to include in user XML/JSON rendering. #
  #------------------------------------------------#
  
  def user_exceptions
    [:salt, :remember_token_expires_at, :crypted_password, :admin, :activation_code, :remember_token, :secret, :can_upload, :email]
  end
  
  def user_methods
    [:avatar_large, :avatar_medium, :avatar_small, :avatar_tiny]
  end
  
  def user_includes
    {
      :friends => {:only => :id, :methods => [], :include => []},
      :inverse_friends => {:only => :id, :methods => [], :include => []},
      :soundwalks => {:only => :id, :methods => [], :include => []}
    }
  end
  
  def user_options
    {:methods => user_methods, :except => user_exceptions, :include => user_includes}
  end
end
