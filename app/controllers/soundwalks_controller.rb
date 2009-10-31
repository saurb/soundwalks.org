class SoundwalksController < ApplicationController
  layout 'site'
  
  before_filter :login_required, :except => ['index', 'show', 'locations']
  
  append_before_filter :get_soundwalk_from_current_user, 
    :only => ['destroy', 'edit', 'update']
  append_before_filter :get_all_soundwalks,
    :only => ['friends', 'index']
    
  # GET /soundwalks
  def index    
    if logged_in? && current_user.id
      puts 'ok!'
    end
      
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks.to_xml(:only => :id, :include => [], :except => []), :status => :ok}
      format.json {render :json => @soundwalks.to_json(:only => :id, :include => [], :except => []), :status => :ok, :callback => params[:callback]}
    end
  end
  
  # GET /soundwalks/:id
  def show
    get_soundwalk
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk.to_xml(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :ok}
      format.json {render :json => @soundwalk.to_json(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :ok, :callback => params[:callback]}
    end
  end
  
  def locations
    get_soundwalk
    
    respond_to do |format|
      format.html {redirect_to @soundwalk}
      
      # This is pretty ugly. Would be nice if Rails could serialize arrays as XML properly.
      format.xml {render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<locations type='array'>\n" + @soundwalk.locations.collect{|location| "\t<location>\n\t\t<time type='datetime'>#{location[0]}</time>\n\t\t<lat type='decimal'>#{location[1]}</lat>\n\t\t<lng type='decimal'>#{location[2]}</lng>\n\t</location>"}.join("\n") + "</locations>"}
      format.json {render :json => @soundwalk.locations.collect{|location| {:time => location[0], :lat => location[1], :lng => location[2]}}, :callback => params[:callback]}
    end
  end
  
  # GET /soundwalks/new
  def new    
    if @current_user.can_upload
      @soundwalk = current_user.soundwalks.build
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @soundwalk.to_xml(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions)}
        format.json {render :json => @soundwalk.to_json(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :callback => params[:callback]}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "You do not have access to upload features. If you believe you should, contact us."
          redirect_back_or_default '/'
        }
        format.xml {render :xml => @soundwalk.to_xml(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions)}
        format.json {render :json => @soundwalk.to_json(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :callback => params[:callback]}
      end
    end
  end
  
  # POST /soundwalks
  def create
    if @current_user.can_upload    
      @soundwalk = current_user.soundwalks.build(params[:soundwalk])
        
      respond_to do |format|
        if @soundwalk.save
          format.html {
            if params[:continue]
              redirect_to "/soundwalks/#{@soundwalk.id}/sounds/uploader"
            else
              redirect_to @soundwalk
            end
          }
          format.xml {render :xml => @soundwalk.to_xml(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :created, :location => @soundwalk}
          format.json {render :json => @soundwalk.to_json(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :created, :location => @soundwalk, :callback => params[:callback]}
        else
          format.html {render :action => 'new'}
          format.xml {render :xml => @soundwalk.errors, :status => :unprocessible_entity}
          format.json {render :json => @soundwalk.errors, :status => :unprocessible_entity, :callback => params[:callback]}
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
  
  # DELETE /soundwalks/:id
  def destroy    
    @soundwalk.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = "Your &quot;#{@soundwalk.title}&quot; soundwalk was deleted."
        redirect_back_or_default(user_name_path(current_user))
      }
      format.xml {head :ok}
      format.json {head :ok, :callback => params[:callback]}
    end
  end
  
  # GET /soundwalks/:id/edit
  def edit
  end
  
  # POST /soundwalks/:id
  def update
    respond_to do |format|
      if @soundwalk.update_attributes(params[:soundwalk])
        format.html {
          flash[:notice] = 'Soundwalk was successfully updated.'
          redirect_to @soundwalk
        }
        format.xml {render :xml => @soundwalk.to_xml(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :ok}
        format.json {render :json => @soundwalk.to_json(:methods => soundwalk_methods, :include => soundwalk_includes, :except => soundwalk_exceptions), :status => :ok, :callback => params[:callback]}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessable_entity}
        format.json {render :json => @soundwalk.errors, :status => :unprocessable_entity, :callback => params[:callback]}
      end
    end
  end
  
  protected
  def get_soundwalk_from_current_user
    @soundwalk = current_user.soundwalks.find(params[:id])
  end
  
  def get_all_soundwalks
    @pages = (Soundwalk.count / 20.0).ceil
    @page = (defined? params[:page]) ? params[:page].to_i : 0
    @soundwalks = Soundwalk.find(:all, :limit => 20, :offset => @page * 20, :order => "created_at DESC, title", :conditions => {:privacy => 'public'})
  end
  
  def get_soundwalk
    user_id = Soundwalk.find(params[:id], :select => 'user_id').read_attribute(:user_id)
    
    if logged_in?
      if user_id == current_user.id
        @soundwalk = Soundwalk.find(params[:id])
      else
        begin
          @soundwalk = Soundwalk.find(params[:id], :conditions => {:privacy => 'public'})
        rescue
          @soundwalk = current_user.following_soundwalks.find(params[:id])
        end
      end
    else
      @soundwalk = Soundwalk.find(params[:id], :conditions => {:privacy => 'public'})
    end
  end
  
  def soundwalk_includes
    {:sounds => {:only => :id, :methods => [], :include => []}}
  end
  
  def soundwalk_methods
    [:formatted_description, :formatted_lat, :formatted_lng, :user_login]
  end
  
  def soundwalk_exceptions
    #[:locations]
    []
  end
end
