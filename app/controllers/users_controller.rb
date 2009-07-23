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
    respond_to do |format|
      format.html {render :layout => 'site'}
      format.xml {render :xml => @user}
    end
  end
  
  # GET /users/:id/edit
  def edit
    if current_user.id != @user.id
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      render :layout => 'site'
    end
  end
  
  # POST /users/:id/edit
  def update
    if current_user.id != @user.id
      flash[:error] = "You are not authorized to access this account."
      redirect_back_or_default('/')
    else
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html {
            flash.now[:notice] = "Your profile has been updated."
            render :layout => 'site', :action => "edit"
          }
          format.xml {render :xml => :ok}
        else
          format.html {render :layout => 'site', :action => "edit"}
          format.xml {render :xml => @user.errors, :status => :unprocessable_entity}
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
    end
  end
end
