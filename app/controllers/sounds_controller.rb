require 'mime/types'

class SoundsController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  append_before_filter :get_soundwalk, 
    :only => ['show']
  append_before_filter :get_soundwalk_from_current_user,
    :only => ['edit', 'update', 'new', 'create', 'destroy', 'recalculate']
  append_before_filter :get_sound_from_soundwalk,
    :only => ['show', 'edit', 'update', 'destroy', 'recalculate']
  
  # GET /soundwalks/:soundwalk_id/sounds/:id
  def show        
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
      format.wav {send_file @sound.sound_path, :type => 'application/wav'}
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
    if params[:sound]
      if params[:sound]['recorded_at']
        params[:sound]['recorded_at'] = Time.at(params[:sound]['recorded_at'].to_i)
      end
    end
    
    @sound = @soundwalk.sounds.build(params[:sound])
    
    respond_to do |format|    
      if @sound.save
        format.html {redirect_to @soundwalk}#soundwalk_sound_path(@soundwalk, @sound)}
        format.xml {render :xml => @sound, :status => :created, :location => soundwalk_sound_path(@soundwalk, @sound)}
        wants.json {:result => 'success', :sound => @sound.id}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
        wants.json {:result => 'error', :error => @sound.errors.full_messages.to_sentence}
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
