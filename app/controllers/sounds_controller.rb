require 'mime/types'
Mime::Type.register "audio/x-wav", :wav

class SoundsController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  append_before_filter :get_soundwalk, 
    :only => ['show', 'index']
  append_before_filter :get_soundwalk_from_current_user,
    :only => ['edit', 'update', 'new', 'create', 'destroy', 'recalculate', 'uploader']
  append_before_filter :get_sound_from_soundwalk,
    :only => ['show', 'edit', 'update', 'destroy', 'recalculate']
  
  # GET /soundwalks/:soundwalk_id/sounds
  def index
    respond_to do |format|
      format.html {redirect_to @soundwalk}
    end
  end
  
  # GET /soundwalks/:soundwalk_id/sounds/:id
  def show        
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
      format.wav {send_file 'public/data/sounds/0000/0000/' + @sound.filename, :type => 'audio/x-wav'}
    end
  end
  
  # GET /soundwalks/:soundwalk_id/sounds/:id/edit
  def edit
  end
  
  # POST /soundwalks/:soundwalk_id/sounds/:id
  def update
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
  
  def uploader
    @sound = @soundwalk.sounds.build
 
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
    
  # GET /soundwalks/:soundwalk_id/sounds/new
  def new
    @sound = @soundwalk.sounds.build
 
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  # POST /soundwalks/:soundwalk_id/sounds
  def create    
    if params[:recorded_at]
      params[:sound]['recorded_at'] = Time.parse(params[:recorded_at])
    end
    
    params[:sound]['user_id'] = current_user.id
    
    @sound = @soundwalk.sounds.build(params[:sound])
    
    respond_to do |format|
      if @sound.save
        format.html {redirect_to @soundwalk}#soundwalk_sound_path(@soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :created, :location => soundwalk_sound_path(@soundwalk, @sound)}
        format.json {render :json => {
          :result => 'success', 
          :location => soundwalk_sound_path(@soundwalk, @sound),
          :sound => {
            :content_type => @sound.content_type,
            :updated_at => @sound.updated_at.httpdate,
            :size => @sound.size,
            :hop_size => @sound.hop_size,
            :frame_size => @sound.frame_size,
            :soundwalk_id => @sound.soundwalk_id,
            :recorded_at => @sound.recorded_at.httpdate,
            :frame_length => @sound.frame_length,
            :sample_rate => @sound.sample_rate,
            :lng => @sound.lng,
            :lat => @sound.lat,
            :id => @sound.id,
            :description => @sound.description,
            :filename => @sound.filename,
            :user_id => @sound.user_id,
            :spectrum_size => @sound.spectrum_size,
            :samples => @sound.samples,
            :state => @sound.state,
            :hop_length => @sound.hop_length,
            :frames => @sound.frames,
            :created_at => @sound.created_at.httpdate
          }
        }
      }
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
        format.json {render :json => {:result => 'error', :error => @sound.errors.full_messages.to_sentence}}
      end
    end
  end
  
  # DELETE /soundwalks/:soundwalk_id/sounds/:id
  def destroy  
    @sound.destroy
    
    respond_to do |format|
      format.html {redirect_to soundwalk_url(@soundwalk)}
      format.xml {head :ok}
      format.js
    end
  end
  
  # POST /soundwalks/:soundwalk_id/sounds/:id/recalculate
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
  
  protected
  def get_soundwalk
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
  end
  
  def get_soundwalk_from_current_user
    @soundwalk = current_user.soundwalks.find(params[:soundwalk_id])
  end
  
  def get_sound_from_soundwalk
    @sound = @soundwalk.sounds.find(params[:id])
  end
end
