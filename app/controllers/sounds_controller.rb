class SoundsController < ApplicationController
  before_filter :login_required
  append_before_filter :get_user, :except => ['new', 'create']
  append_before_filter :get_user_soundwalk, :except => ['new', 'create']
  append_before_filter :get_soundwalk, :only => ['new', 'create']
  append_before_filter :get_sounds, :only => ['index', 'show']
  append_before_filter :get_sound, :except => ['index', 'new', 'create']
  
  # Before filters.  
  def get_soundwalk
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
  end
  
  def get_user_soundwalk
    @soundwalk = @user.soundwalks.find(params[:soundwalk_id])
  end
  
  def get_user
    @user = @soundwalk.user #User.find(params[:user_id])
  end
  
  def get_sound
    @sound = @soundwalk.sounds.find(params[:id])
  end
  
  def get_sounds
    @sounds = @soundwalk.sounds.find(:all)
  end
  
  # Methods.
  def index
    respond_to do |format|
      format.html
      format.xml {render :xml => @sounds}
    end
  end
  
  def show    
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  def new
     @sound = @soundwalk.sounds.build
     
     respond_to do |format|
       format.html
       format.xml {render :xml => @sound}
     end
  end
  
  def create
    @sound = @soundwalk.sounds.build(params[:sound])
    @sound.file = params[:upload]['file']
    
    respond_to do |format|    
      if @sound.save
        format.html {redirect_to user_soundwalk_sound_url(@user, @soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :created, :location => @sound}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  def destroy    
    @sound.destroy
    
    respond_to do |format|
      format.html {redirect_to user_soundwalk_sounds_url(@user, @soundwalk)}
      format.xml {head :ok}
    end
  end
end
