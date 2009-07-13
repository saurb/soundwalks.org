Mime::Type.register 'application/wav', :wav

class SoundsController < ApplicationController
  before_filter :login_required  
  append_before_filter :get_soundwalk
  append_before_filter :get_sounds, :only => ['index', 'show']
  append_before_filter :get_sound, :except => ['index', 'new', 'create']
  
  # Before filters.  
  def get_soundwalk
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
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
      format.wav {send_file @sound.sound_path, :type => 'application/wav'}
    end
  end
  
  def edit
  end
  
  def recalculate
    @sound.analyze_sound
    
    respond_to do |format|
      if @sound.save
        format.html {redirect_to soundwalk_sound_url(@soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :updated, :location => @sound}
      else
        flash[:errors] = 'Problem recalculating feature values.'
        format.html {redirect_to soundwalk_sound_url(@soundwalk, @sound)}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  def update    
    @sound.file = params[:upload]['file']
    
    respond_to do |format|
      if @sound.update_attributes(params[:sound])
        flash[:notice] = 'Sound was successfully updated.'
        format.html {redirect_to soundwalk_sound_url(@soundwalk, @sound)}
        format.xml {head :ok}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
      end
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
        flash[:notice] = 'Sound was successfully created.'
        format.html {redirect_to soundwalk_sound_url(@soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :created, :location => @sound}
      else
        flash[:notice] = 'There was an error creating the sound.'
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  def destroy    
    @sound.destroy
    
    respond_to do |format|
      format.html {redirect_to soundwalk_sounds_url(@soundwalk)}
      format.xml {head :ok}
    end
  end
end
