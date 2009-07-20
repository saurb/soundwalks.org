Mime::Type.register 'application/wav', :wav

class SoundsController < ApplicationController
  layout 'site'
  
  before_filter :login_required  
  
  # Methods.
  def index
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sounds = @soundwalk.sounds.find(:all)
    
    respond_to do |format|
      format.html {redirect_to @soundwalk}
      format.xml {render :xml => @sounds}
    end
  end
  
  def show    
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sounds = @soundwalk.sounds
    @sound = @soundwalk.sounds.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
      format.wav {send_file @sound.sound_path, :type => 'application/wav'}
    end
  end
  
  def edit
  end
  
  def recalculate
    @soundwalk = @current_user.soundwalks.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:id])
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
    @soundwalk = @current_user.soundwalks.find(:soundwalk_id)
    @sound = @soundwalk.sounds.find(params[:id])
    
    if params[:upload]
      @soundwalk.file = params[:upload]['sound_file']
    end
    
    respond_to do |format|
      if @sound.update_attributes(params[:sound])
        flash[:notice] = 'Sound was successfully updated.'
        format.html {redirect_to soundwalk_sound_path(@soundwalk, @sound)}
        format.xml {head :ok}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
      end
    end
  end
  
  def new
    @soundwalk = @current_user.soundwalks.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.build
 
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  def create
    @soundwalk = @current_user.soundwalks.find(params[:soundwalk_id])
    
    if params[:sound]
      if params[:sound]['recorded_at']
        params[:sound]['recorded_at'] = Time.at(params[:sound]['recorded_at'].to_i)
      end
    end
    
    @sound = @soundwalk.sounds.build(params[:sound])
    failed = false
    
    if params[:upload]      
      @sound.sound_file = params[:upload]['sound_file']
      failed = true if !@sound.save
    else
      failed = true
    end
    
    respond_to do |format|    
      if !failed
        format.html {redirect_to @soundwalk}#soundwalk_sound_path(@soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :created, :location => soundwalk_sound_path(@soundwalk, @sound)}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  def destroy  
    @soundwalk = @current_user.soundwalks.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:id])  
    @sound.destroy
    
    respond_to do |format|
      format.html {redirect_to soundwalk_sounds_url(@soundwalk)}
      format.xml {head :ok}
    end
  end
end
