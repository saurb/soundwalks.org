class UsersController < ApplicationController  
  layout 'user', :except => [:edit, :update, :show]
  
  before_filter :login_required, :only => [:settings]
  before_filter :get_user, :except => [:create, :activate, :settings]
  
  # GET /users/new, /signup
  def new
    @user = User.new
  end
  
  # POST /users/new
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
  
  # GET /users/activate/:activation_code
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
  
  # PUT /users/:id/suspend
  def suspend
    @user.suspend! 
    redirect_to users_path
  end
  
  # PUT /users/:id/unsuspend
  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end
  
  # DELETE /users/:id
  def destroy
    @user.delete!
    redirect_to users_path
  end
  
  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # GET /users/:id, /:login
  def show
    get_soundwalks_from_user
    
    respond_to do |format|
      format.html {render :layout => 'site'}
      format.xml {render :xml => @user.to_xml(:except => user_exceptions, :methods => user_methods)}
      format.js {render :json => @user.to_json(:except => user_exceptions, :methods => user_methods)}
    end
  end
  
  def settings
    redirect_to edit_user_path(current_user)
  end
  
  # GET /users/:id/edit
  def edit
    if current_user.id != @user.id && !@user.admin
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      render :layout => 'site'
    end
  end
  
  # POST /users/:id/edit
  def update
    if current_user.id != @user.id && !@user.admin
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      success = true
      
      if params[:new_password] 
        if User.authenticate(@user.login, params[:old_password])
          puts 'Success'
          puts params[:old_password]
          params[:user][:password] = params[:new_password]
        else
          puts 'No success'
          success = false
          flash.now[:error] = "Incorrect old password."
          render :layout => 'site', :action => 'edit'
        end
      else
        puts 'No password'
      end
      
      if success
        respond_to do |format|
          if @user.update_attributes(params[:user])
            format.html {
              flash.now[:notice] = "Your profile has been updated."
              render :layout => 'site', :action => "edit"
            }
            format.xml {render :xml => @user.to_xml(:except => user_exceptions, :methods => user_methods), :status => :ok}
            format.js {render :json => @user.to_json(:except => user_exceptions, :methods => user_methods), :status => :ok}
          else
            format.html {render :layout => 'site', :action => "edit"}
            format.xml {render :xml => @user.errors, :status => :unprocessable_entity}
            format.js {render :json => @user.errors, :status => :unprocessable_entity}
          end
        end
      end
    end
  end
  
  # GET /:login/followers
  def followers
    render :layout => 'site'
  end
  
  # GET /:login/following
  def following
    render :layout => 'site'
  end
  
protected
  def get_user
    if params[:id]
      @user = User.find(params[:id])
    elsif params[:username]
      @user = User.find(:first, :conditions => {:login => params[:username]})
      
      if !@user
        flash[:error] = "User &quot;#{params[:username]}&quot; could not be found."
        redirect_back_or_default '/'
      end
    end
  end
  
  def get_soundwalks_from_user
    friendships = @user.friendships.find(:all, :conditions => "friend_id=#{current_user.id}")
    
    if logged_in? && @user.id == current_user.id
      @soundwalks = @user.soundwalks.find(:all)
    elsif logged_in? && friendships != nil && friendships.size > 0
      @soundwalks = @user.soundwalks.find(:all, :conditions => {:privacy => ['friends', 'public']})
    else
      @soundwalks = @user.soundwalks.find(:all, :conditions => {:privacy => 'public'})
    end
  end
  
  def user_exceptions
    [:salt, :remember_token_expires_at, :crypted_password, :admin, :activation_code, :remember_token, :secret, :can_upload, :email]
  end
  
  def user_methods
    [:avatar_large, :avatar_medim, :avatar_small, :avatar_tiny]
  end
end
