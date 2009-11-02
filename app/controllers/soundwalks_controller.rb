class SoundwalksController < ApplicationController
  layout 'site', :except => [:destroy]
  
  before_filter :login_required, :except => ['index', 'show', 'locations']
  append_before_filter :get_soundwalk_from_current_user, :only => ['destroy', 'edit', 'update']
  append_before_filter :get_all_soundwalks, :only => ['friends', 'index']
  
  #------------------------------------------------------------------------#
  # GET /soundwalks?page=                                                  #
  #   Show a list of all the most recent soundwalks that the user can see. #
  #   JSON/XML only show IDs for each soundwalk.                           #
  #   Limited to 20 soundwalks per page, offset by an option page number.  #
  #                                                                        #
  #   TODO: Decide on a consistent pagination method (offset or page)      #
  #------------------------------------------------------------------------#
  
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
  
  #----------------------------------------#
  # GET /soundwalks/:id                    #
  #   Shows information about a soundwalk. #
  #----------------------------------------#
  
  def show
    get_soundwalk
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk.to_xml(soundwalk_options), :status => :ok}
      format.json {render :json => @soundwalk.to_json(soundwalk_options), :status => :ok, :callback => params[:callback]}
    end
  end
  
  #-----------------------------------------------------------------#
  # GET /soundwalks/:id/locations                                   #
  #   Shows a list of locations in the GPS trace for a soundwalk.   #
  #   This trace is excluded from the view of the entire soundwalk. #
  #-----------------------------------------------------------------#
  
  def locations
    get_soundwalk
    
    respond_to do |format|
      format.html {redirect_to @soundwalk}
      
      # This is pretty ugly. Would be nice if Rails could serialize arrays as XML properly.
      format.xml {render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<locations type='array'>\n" + @soundwalk.locations.collect{|location| "\t<location>\n\t\t<time type='datetime'>#{location[0]}</time>\n\t\t<lat type='decimal'>#{location[1]}</lat>\n\t\t<lng type='decimal'>#{location[2]}</lng>\n\t</location>"}.join("\n") + "</locations>"}
      format.json {render :json => @soundwalk.locations.collect{|location| {:time => location[0], :lat => location[1], :lng => location[2]}}, :callback => params[:callback]}
    end
  end
  
  #-------------------------------------------------------------------------------#
  # GET /soundwalks/new                                                           #
  #   Shows the form for a new soundwalk.                                         #
  #   Returns an empty soundwalk option to XML/JSON.                              #
  #   User must be logged in and have uploading privileges to view the HTML form. #
  #-------------------------------------------------------------------------------#
  
  def new
    if @current_user.can_upload
      @soundwalk = current_user.soundwalks.build
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @soundwalk.to_xml(soundwalk_options)}
        format.json {render :json => @soundwalk.to_json(soundwalk_options), :callback => params[:callback]}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "You do not have access to upload features. If you believe you should, contact us."
          redirect_back_or_default '/'
        }
        format.xml {render :xml => @soundwalk.to_xml(soundwalk_options)}
        format.json {render :json => @soundwalk.to_json(soundwalk_options), :callback => params[:callback]}
      end
    end
  end
  
  #---------------------------------------------------------#
  # POST /soundwalks                                        #
  #   Create a new soundwalk from posted (form) data.       #
  #   User must be logged in and have uploading privileges. #
  #---------------------------------------------------------#
  
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
          format.xml {render :xml => @soundwalk.to_xml(soundwalk_options), :status => :created, :location => @soundwalk}
          format.json {render :json => @soundwalk.to_json(soundwalk_options), :status => :created, :location => @soundwalk, :callback => params[:callback]}
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
  
  #-------------------------------------------------#
  # DELETE /soundwalks/:id                          #
  #   Deletes a soundwalk.                          #
  #   User must be logged in and own the soundwalk. #
  #-------------------------------------------------#
  
  def destroy
    @soundwalk.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = "Your &quot;#{@soundwalk.title}&quot; soundwalk was deleted."
        redirect_back_or_default(user_name_path(current_user))
      }
      format.xml {head :ok}
      format.json {head :ok, :callback => params[:callback]}
      format.js
    end
  end
  
  #-------------------------------------------------#
  # GET /soundwalks/:id/edit                        #
  #   Shows the HTML form to edit a soundwalk.      #
  #   User must be logged in and own the soundwalk. #
  #-------------------------------------------------#
  
  def edit
  end
  
  #-------------------------------------------------#
  # POST /soundwalks/:id                            #
  #   Updates a soundwalk given posted (form) data. #
  #   User must be logged in and own the soundwalk. #
  #-------------------------------------------------#
  
  def update
    respond_to do |format|
      if @soundwalk.update_attributes(params[:soundwalk])
        format.html {
          flash[:notice] = 'Soundwalk was successfully updated.'
          redirect_to @soundwalk
        }
        format.xml {render :xml => @soundwalk.to_xml(soundwalk_options), :status => :ok}
        format.json {render :json => @soundwalk.to_json(soundwalk_options), :status => :ok, :callback => params[:callback]}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessable_entity}
        format.json {render :json => @soundwalk.errors, :status => :unprocessable_entity, :callback => params[:callback]}
      end
    end
  end
  
protected
  
  #--------------------------------------------------------#
  # Fetches the soundwalk from the current logged in user. #
  #   User must be logged in and own the soundwalk.        #
  #   Used for all create/update/edit methods.             #
  #--------------------------------------------------------#
  
  def get_soundwalk_from_current_user
    @soundwalk = current_user.soundwalks.find(params[:id])
  end
  
  #------------------------------------------------------------------------------------------------#
  # Fetches all public soundwalks, limited to 20, given an optional offset (see GET /soundwalks).  #
  #------------------------------------------------------------------------------------------------#
  
  def get_all_soundwalks
    @pages = (Soundwalk.count / 20.0).ceil
    @page = (defined? params[:page]) ? params[:page].to_i : 0
    @soundwalks = Soundwalk.find(:all, :limit => 20, :offset => @page * 20, :order => "created_at DESC, title", :conditions => {:privacy => 'public'})
  end
  
  #----------------------------------------------------------------------------------------------------------------#
  # Fetches any soundwalk.                                                                                         #
  #   Either the user must own the soundwalk, it must be public, or it must be friends-only and the logged-in user #
  #   is followed by the user who owns it.                                                                         #
  #----------------------------------------------------------------------------------------------------------------#
  
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
  
  #-----------------------------------------------------#
  # Options to include in soundwalk XML/JSON rendering. #
  #-----------------------------------------------------#
  
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
  
  def soundwalk_options
    {:methods => soundwalk_methods, :includes => soundwalk_includes, :except => soundwalk_exceptions}
  end
end
