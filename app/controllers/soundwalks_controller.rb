class SoundwalksController < ApplicationController
  layout 'site'
  
  before_filter :login_required, :except => 'public'
  
  # GET /friends
  def friends
    @soundwalks = Soundwalk.find(:all)
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks}
    end
  end
  
  # GET /public
  def public
    @soundwalks = Soundwalk.find(:all)
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks}
    end
  end
  
  # GET /users/:user_id/soundwalks
  def user
    @user = User.find(params[:user_id])
    @soundwalks = @user.soundwalks.find(:all)
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalks}
    end
  end
  
  # GET /soundwalks/:id
  def show
    @soundwalk = Soundwalk.find(params[:id])
    @sounds = @soundwalk.sounds
    @sound = Sound.new
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  # GET /soundwalks/new
  def new
    @soundwalk = @current_user.soundwalks.build
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @soundwalk}
    end
  end
  
  # POST /soundwalks
  def create
    @soundwalk = @current_user.soundwalks.build(params[:soundwalk])
    failed = false
    
    if params[:upload]
      @soundwalk.locations_file = params[:upload]['locations_file']
      failed = true if !@soundwalk.save
    else
      failed = true
    end
    
    respond_to do |format|    
      if !failed
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
      format.html {redirect_to soundwalks_url}
      format.xml {head :ok}
    end
  end
  
  # GET /soundwalks/:id/edit
  def edit
  end
  
  # POST /soundwalks/:id
  def update    
    @soundwalk.locations_file = params[:upload]['locations_file']
    
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
end
