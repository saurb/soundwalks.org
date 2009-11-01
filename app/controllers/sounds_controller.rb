require 'mime/types'
Mime::Type.register "audio/x-wav", :wav
Mime::Type.register "audio/mpeg", :mp3

class SoundsController < ApplicationController
  layout 'site'
  
  before_filter :login_required, :except => ['index', 'show', 'allindex']
  
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
      if params[:show] == 'sounds'
        format.json {render :json => @soundwalk.sounds.to_json(sound_options), :callback => params[:callback], :status => :ok}
        format.xml {render :xml => @soundwalk.sounds.to_xml(sound_options), :status => :ok}
      else
        format.json {render :json => @soundwalk.sounds.collect {|sound| sound.id}, :callback => params[:callback], :status => :ok}
        format.xml {render :xml => @soundwalk.sounds.collect {|sound| sound.id}, :status => :ok}
      end
    end
  end
  
  # GET /sounds
  def allindex
    if params[:distance]
      @sounds = Sound.find_within(params[:distance], :origin => [params[:lat], params[:lng]], :limit => 200, :offset => params[:offset] ? params[:offset] : 0)
    elsif logged_in? && current_user && current_user.admin?
      @soundwalks = Soundwalk.find(:all)
      @sounds = Sound.find(:all)
    end
    
    respond_to do |format|
      format.html if logged_in? & current_user && current_user.admin?
      format.json {render :json => @sounds.to_json(sound_options), :callback => params[:callback]}
      format.xml {render :xml => @sounds.to_xml(sound_options), :callback => params[:callback]}
    end
  end
  
  # GET /soundwalks/:soundwalk_id/sounds/:id
  def show        
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound.to_xml(sound_options)}
      format.json {render :json => @sound.to_json(sound_options), :callback => params[:callback]}
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
        format.xml {render :xml => @sound.to_xml(sound_options), :status => :ok}
        format.json {render :json => @sound.to_json(sound_options), :status => :ok, :callback => params[:callback]}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
        format.json {render :json => @sound.errors, :status => :unprocessable_entity, :callback => params[:callback]}
      end
    end
  end

  def uploader
    @sound = @soundwalk.sounds.build
 
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound.to_xml(sound_options)}
      format.json {render :json => @sound.to_json(sound_options), :callback => params[:callback]}
    end
  end
    
  # GET /soundwalks/:soundwalk_id/sounds/new
  def new
    if @current_user.can_upload
      @sound = @soundwalk.sounds.build
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @sound.to_xml(sound_options)}
        format.json {render :json => @sound.to_json(sound_options), :callback => params[:callback]}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "You do not have access to upload features. If you believe you should, contact us."
          redirect_back_or_default '/'
        }
        format.xml {render :xml => @sound.to_xml(sound_options)}
        format.json {render :json => @sound.to_json(sound_options), :callback => params[:callback]}
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
          node = @sound.build_mds_node
          node.x = 0
          node.y = 0
          node.z = 0
          node.w = 0
          node.save
          
          format.html {redirect_to soundwalk_sound_path(@soundwalk, @sound)}
          format.xml {render :xml => @sound.to_xml(sound_options), :status => :ok, :location => soundwalk_sound_path(@soundwalk, @sound)}
          format.json {render :json => @sound.to_json(sound_options), :status => :ok, :location => soundwalk_sound_path(@soundwalk, @sound), :callbock => params[:callback]}
        else
          format.html {render :action => 'new'}
          format.xml {render :xml => @sound.errors, :status => :unprocessable_entity}
          format.json {render :json => @sound.errors, :status => :unprocessable_entity, :callback => params[:callback]}
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
      format.json {head :ok, :callback => params[:callback]}
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
      format.json {render :json => {:sound_ids => params[:sound_ids]}, :status => :ok, :callback => params[:callback]}
    end
  end
  
  def tag
    if params[:tags]
      tags = params[:tags].split(',').collect {|tag| tag.chomp}
      tags.each {|tag| current_user.tag(@sound, :with => tag, :on => :tags)}
      
      respond_to do |format|
        format.xml {render :xml => {:tags => tags}, :status => :ok}
        format.json {render :json => {:tags => tags}, :status => :ok, :callback => params[:callback]}
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
    
    request_tag_ids = params[:tag_ids] ? split_param(params[:tag_ids]) : []
    request_tag_names = params[:tags] ? split_param(params[:tags]) : []
    request_sound_ids = params[:sound_ids] ? split_param(params[:sound_ids]) : []
    
    tag_results = Tag.find(:all, :conditions => ["name in (:names) or id in (:ids)", {:names => request_tag_names, :ids => request_tag_ids}])
    sound_results = Sound.find(:all, :conditions => {:id => request_sound_ids})
    
    verified_ids = []
    verified_ids.concat sound_results.collect{|result| result.mds_node.id} if sound_results != nil
    verified_ids.concat tag_results.collect{|result| result.mds_node.id} if tag_results != nil
    
    distribution = Link.query_distribution(sound.mds_node, verified_ids)
    
    distribution.each do |bin|
      sound_ids = sound_results.reject{|result| result.mds_node.id != bin[:id]}.collect{|result| result.id}
      tag_ids = tag_results.reject{|result| result.mds_node.id != bin[:id]}.collect{|result| result.id}
      
      if sound_ids.size > 0
        bin[:type] = 'Sound'
        bin[:id] = sound_ids.first
      elsif tag_ids.size > 0
        bin[:type] = 'Tag'
        bin[:id] = tag_ids.first
      else
        bin[:type] = "Unknown"
      end
    end
    
    respond_to do |format|
      format.json {render :json => distribution, :callback => params[:callback]}
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
  
  def sound_methods
    [:formatted_lat, :formatted_lng, :formatted_recorded_at, :soundwalk_title, :user_id, :user_name, :user_login, :color_red, :color_green, :color_blue]
  end
  
  def sound_includes
    []
  end
  
  def sound_exceptions
    []
  end
  
  def sound_options
    {:methods => sound_methods, :include => sound_includes, :except => sound_exceptions}
  end
end
