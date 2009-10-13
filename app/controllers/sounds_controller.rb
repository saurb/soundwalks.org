require 'mime/types'
Mime::Type.register "audio/x-wav", :wav
Mime::Type.register "audio/mpeg", :mp3

class SoundsController < ApplicationController
  layout 'site'
  
  before_filter :login_required, :except => ['index', 'show']
  
  append_before_filter :get_soundwalk, 
    :only => ['show', 'index', 'query_set']
  append_before_filter :get_soundwalk_from_current_user,
    :only => ['edit', 'update', 'new', 'create', 'destroy', 'recalculate', 'uploader', 'tag', 'analyze']
  append_before_filter :get_sound_from_soundwalk,
    :only => ['show', 'edit', 'update', 'destroy', 'recalculate', 'tag', 'analyze']
  
  # GET /soundwalks/:soundwalk_id/sounds
  def index
    respond_to do |format|
      format.html {redirect_to @soundwalk}
      format.js {
        if params[:show] == 'sounds'
          render :json => @soundwalk.sounds, :callback => params[:callback], :status => :ok
        else
          render :json => @soundwalk.sounds.collect {|sound| sound.id}, :callback => params[:callback], :status => :ok
        end
      }
    end
  end
  
  # GET /sounds
  def allindex
    if params[:distance]
      @sounds = Sound.find_within(params[:distance], :origin => [params[:lat], params[:lng]], :limit => 500)
    elsif current_user.admin?
      @soundwalks = Soundwalk.find(:all)
      @sounds = Sound.find(:all)
    end
    
    respond_to do |format|
      format.xml {render :xml => @sounds}
      format.js {render :json => @sounds.collect{|sound| ActiveSupport::JSON.decode(sound.to_json :methods => [:formatted_lat, :formatted_lng, :formatted_recorded_at, :soundwalk_title, :user_id, :user_name, :user_login])}, :callback => params[:callback]}
      
      if current_user.admin?
        format.html
      end
    end
  end
  
  # GET /soundwalks/:soundwalk_id/sounds/:id
  def show        
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound, :callback => params[:callback]}
      format.js {render :json => @sound, :callback => params[:callback]}
      format.wav {send_file @sound.full_filename, :type => 'audio/x-wav'}
      format.mp3 {send_file @sound.full_filename + '.mp3', :type => 'audio/mpeg'}
    end
  end
  
  # GET /soundwalks/:soundwalk_id/sounds/:id/edit
  def edit
  end
  
  # POST /soundwalks/:soundwalk_id/sounds/:id
  def update
    respond_to do |format|
      if @sound.update_attributes(params[:sound])
        format.html {
          flash[:notice] = 'Sound was successfully updated.'
          redirect_to soundwalk_sound_path(@soundwalk, @sound)
        }
        format.xml {render :xml => @sound, :status => :ok, :callback => params[:callback]}
        format.js {render :json => @sound, :status => :ok, :callback => params[:callback]}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
        format.js {render :json => @sound.errors, :status => :unprocessable_entity}
      end
    end
  end

  def uploader
    @sound = @soundwalk.sounds.build
 
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
      format.js {render :json => @sound}
    end
  end
    
  # GET /soundwalks/:soundwalk_id/sounds/new
  def new
    if @current_user.can_upload
      @sound = @soundwalk.sounds.build
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @sound}
        format.js {render :json => @sound}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "You do not have access to upload features. If you believe you should, contact us."
          redirect_back_or_default '/'
        }
        format.xml {render :xml => @sound}
        format.js {render :json => @sound}
      end
    end
  end
  
  # POST /soundwalks/:soundwalk_id/sounds
  def create    
    if @current_user.can_upload
      if params[:recorded_at]
        params[:sound]['recorded_at'] = Time.parse(params[:recorded_at])
      end
    
      params[:sound]['user_id'] = current_user.id
      
      @sound = @soundwalk.sounds.build(params[:sound])
    
      respond_to do |format|
        if @sound.save
          format.html {redirect_to soundwalk_sound_path(@soundwalk, @sound)}
          format.xml {render :xml => @sound, :status => :ok, :location => soundwalk_sound_path(@soundwalk, @sound)}
          format.json {render :json => @sound, :status => :ok, :location => soundwalk_sound_path(@soundwalk, @sound)}
        else
          format.html {render :action => 'new'}
          format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
          format.json {render :json => @sound.errors, :status => :unprocessable_entity}
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "You do not have access to upload features. If you believe you should, contact us."
          redirect_back_or_default '/'
        }
      end
    end
  end
  
  # DELETE /soundwalks/:soundwalk_id/sounds/:id
  def destroy  
    @sound.destroy
    
    respond_to do |format|
      format.html {redirect_to soundwalk_url(@soundwalk)}
      format.xml {head :ok}
      format.js {head :ok}
    end
  end
  
  # DELETE /soundwalks/:soundwalk_id/sounds
  def delete_multiple
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    
    for id in params[:sound_ids]
      @sound = @soundwalk.sounds.find(id)
      @sound.destroy
    end

    respond_to do |format|
      format.xml {render :xml => {:sound_ids => params[:sound_ids]}, :status => :ok}
      format.js {render :json => {:sound_ids => params[:sound_ids]}, :status => :ok}
    end
  end
  
  def tag
    if params[:tags]
      tags = params[:tags].split(',').collect {|tag| tag.chomp}
      tags.each {|tag| current_user.tag(@sound, :with => tag, :on => :tags)}
      
      respond_to do |format|
        format.xml {render :xml => {:tags => tags}, :status => :ok}
        format.js {render :json => {:tags => tags}, :status => :ok}
      end
    end
  end
  
  def analyze
    @sound.analyze_sound
    
    respond_to do |format|
      format.html {
        flash[:notice] = "Sound #{@sound.id} (#{@sound.filename}) successfully analyzed."
        redirect_to(soundwalk_sound_path(@soundwalk, @sound))
      }
    end
  end
  
  def query_set
    sound = @soundwalk.sounds.find(params[:sound_id])
    response = []
    
    verified_tag_ids = []
    verified_tag_names = []
    verified_sound_ids = []
    
    request_tag_ids = []
    request_tag_names = []
    request_sound_ids = []
    
    request_tag_ids = split_param(params[:tag_ids]) if params[:tag_ids]
    request_tag_names = split_param(params[:tags]) if params[:tags]
    request_sound_ids = split_param(params[:sound_ids]) if params[:sound_ids]
    
    tag_results = Tag.find(:all, :conditions => ["name in (:names) or id in (:ids)", {:names => request_tag_names, :ids => request_tag_ids}])
      
    if tag_results != nil
      tag_results.each do |result|
        verified_tag_ids.push result.id
        verified_tag_names.push result.name
      end
    end
    
    sound_results = Sound.find(:all, :conditions => {:id => request_sound_ids})
    
    if sound_results != nil
      sound_results.each do |result|
        verified_sound_ids.push result.id
      end
    end
    
    distribution = Link.query_distribution(sound, {'Tag' => verified_tag_ids, 'Sound' => verified_sound_ids})
    
    respond_to do |format|
      format.js {render :json => distribution}
      format.xml {render :xml => distribution}
    end
  end
  
  protected
  def get_soundwalk
    user_id = Soundwalk.find(params[:soundwalk_id], :select => 'user_id').read_attribute(:user_id)
    
    if logged_in?
      if user_id == current_user.id
        @soundwalk = Soundwalk.find(params[:soundwalk_id])
      else
        begin
          @soundwalk = Soundwalk.find(params[:soundwalk_id], :conditions => {:privacy => 'public'})
        rescue
          @soundwalk = current_user.following_soundwalks.find(params[:soundwalk_id])
        end
      end
    else
      @soundwalk = Soundwalk.find(params[:soundwalk_id], :conditions => {:privacy => 'public'})
    end
  end
  
  def get_soundwalk_from_current_user
    @soundwalk = current_user.soundwalks.find(params[:soundwalk_id])
  end
  
  def get_sound_from_soundwalk
    @sound = @soundwalk.sounds.find(params[:id])
  end
  
  def split_param(param)
    param.split(',').collect{|value| value.chomp}
  end
end
