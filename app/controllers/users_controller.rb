class UsersController < ApplicationController  
  layout 'user', :except => [:edit, :update, :show]
  
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :only => :settings
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :show, :edit, :update]
  
  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    if params[:user]['secret'] != '52521082'
      @user = User.new(params[:user])
      flash[:error] = "Incorrect secret phrase."
      render :action => 'new'
    else
      logout_keeping_session!
      @user = User.new(params[:user])
      @user.register! if @user && @user.valid?
      success = @user && @user.valid?
      if success && @user.errors.empty?
        redirect_back_or_default('/')
        flash[:notice] = "Thanks for signing up!  We're sending you an email with a link to activate your account. In the mean time, feel free to explore all the publicly available soundwalks."
      else
        flash[:error]  = "There were some problems making your account. Please review any errors and try again."
        render :action => 'new'
      end
    end
  end

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

  def suspend
    @user.suspend! 
    redirect_to users_path
  end
  
  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end
  
  def destroy
    @user.delete!
    redirect_to users_path
  end
  
  def purge
    @user.destroy
    redirect_to users_path
  end
  
  def show
    @soundwalks = @user.soundwalks.find(:all)
    
    respond_to do |format|
      format.html {render :layout => 'site'}
      format.xml {render :xml => @user}
    end
  end
  
  def settings
    if logged_in?
      redirect_to edit_user_path(current_user)
    else
      respond_to do |format|
        format.html {
          flash[:error] = 'Cannot access settings because you are not logged in.'
          redirect_back_or_default('/')
        }
      end
    end
  end
  
  def edit
    if current_user.id != @user.id
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    end
    
    render :layout => 'site'
  end
  
  def update
    if current_user.id != @user.id
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = "Your profile has been updated."
          format.html {render :layout => 'site', :action => "edit"}
          format.xml {render :xml => :ok}
        else
          format.html {render :layout => 'site', :action => "edit"}
          format.xml {render :xml => @user.errors, :status => :unprocessable_entity}
        end
      end
    end
  end
  
protected
  def find_user
    @user = User.find(params[:id])
  end
end
