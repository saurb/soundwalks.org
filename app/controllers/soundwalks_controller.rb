class SoundwalksController < ApplicationController
  layout 'site'
  
  before_filter :login_required#, :except => 'public'
  append_before_filter :get_soundwalk_from_current_user, 
    :only => ['destroy', 'edit', 'update']
  append_before_filter :get_all_soundwalks,
    :only => ['friends', 'index']
  append_before_filter :get_soundwalk,
    :only => ['show']
  
  # GET /soundwalks
  def index
    @meta[:title] = 'Public Timeline'
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks}
    end
  end
  
  # GET /soundwalks/:id
  def show
    @meta[:title] = @soundwalk.title
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  # GET /soundwalks/new
  def new
    @meta[:title] = "New Soundwalk"
    
    @soundwalk = current_user.soundwalks.build
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  # POST /soundwalks
  def create
    @meta[:title] = "New Soundwalk"
    
    @soundwalk = current_user.soundwalks.build(params[:soundwalk])
        
    respond_to do |format|    
      if @soundwalk.save
        format.html {redirect_to @soundwalk}
        format.xml {render :xml => @soundwalk, :status => :created, :location => @soundwalk}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessible_entity}
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
      format.js
    end
  end
  
  # GET /soundwalks/:id/edit
  def edit
    @meta[:title] = @soundwalk.title + ': Edit'
  end
  
  # POST /soundwalks/:id
  def update
    @meta[:title] = @soundwalk.title + ': Edit'
    
    respond_to do |format|
      if @soundwalk.update_attributes(params[:soundwalk])
        flash[:notice] = 'Soundwalk was successfully updated.'
        format.html {redirect_to @soundwalk}
        format.xml {head :ok}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @soundwalk.errors, :status => :unprocessable_entity}
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
    @soundwalks = Soundwalk.find(:all, :limit => 20, :offset => @page * 20, :order => "created_at DESC, title")
  end
  
  def get_soundwalk
    @soundwalk = Soundwalk.find(params[:id])
  end
end
