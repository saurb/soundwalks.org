class SoundwalksController < ApplicationController
  before_filter :login_required
  append_before_filter :get_user
  append_before_filter :get_soundwalk, :except => ['index', 'new', 'create']
  append_before_filter :get_soundwalks, :only => 'index'
  
  # Before filters.
  def get_user
    @user = User.find(params[:user_id])
  end
  
  def get_soundwalk
      @soundwalk = @user.soundwalks.find(params[:id])
  end
  
  def get_soundwalks
    @soundwalks = @user.soundwalks.find(:all)
  end
  
  # Methods.
  def index  
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks}
    end
  end
  
  def show
    @sounds = @soundwalk.sounds
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  def new
    @soundwalk = @user.soundwalks.build
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  def create
    @soundwalk = @user.soundwalks.build(params[:soundwalk])
    @soundwalk.locations_file = params[:upload]['locations_file']
    
    respond_to do |format|    
      if @soundwalk.save
        format.html {redirect_to user_soundwalk_url(@user, @soundwalk)}
        format.xml {render :xml => @soundwalk, :status => :created, :location => @soundwalk}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  def destroy    
    @soundwalk.destroy
    
    respond_to do |format|
      format.html {redirect_to(user_soundwalks_url(@user))}
      format.xml {head :ok}
    end
  end
  
  def edit
  end
  
  def update    
    @soundwalk.locations_file = params[:upload]['locations_file']
    
    respond_to do |format|
      if @soundwalk.update_attributes(params[:soundwalk])
        flash[:notice] = 'Soundwalk was successfully updated.'
        format.html {redirect_to(@soundwalk)}
        format.xml {head :ok}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessable_entity}
      end
    end
  end 
end
