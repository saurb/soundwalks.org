class TagsController < ApplicationController
  before_filter :login_required, :only => :update
  
  #------------------------------------------------------------------------------------------#
  # GET /soundwalks/:soundwalk_id/sounds/:sound_id/tags                                      #
  #   Shows all tags for a given soundwalk.                                                  #
  #   Additionally shows the tags a user has assigned to the sound if the user is logged in. #
  #------------------------------------------------------------------------------------------#
  
  def show
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    
    respond_to do |format|
      format.xml {render :xml => tag_response(@sound)}
      format.json {render :json => tag_response(@sound), :callback => params[:callback]}
    end
  end
  
  #------------------------------------------------------#
  # POST /soundwalks/:soundwalk_id/sounds/:sound_id/tags #
  #   Applies tags to the sound.                         #
  #   User must be logged in.                            #
  #------------------------------------------------------#
    
  def update
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    tags = params[:user_tags]
    
    current_user.tag(@sound, :with => tags, :on => :tags)
    
    respond_to do |format|
      format.xml {render :xml => tag_response(@sound), :status => :ok}
      format.json {render :json => tag_response(@sound), :status => :ok, :callback => params[:callback]}
    end
  end
  
  #-------------------------------------------------------------------------------------------#
  # GET /tags/:id/query_set&tags=&tag_ids=&sound_ids=                                         #
  #   TODO: Make tag_id id, make this accessible as GET /tags/:tag_name/query_set... as well. #
  #-------------------------------------------------------------------------------------------#
  
  def query_set
    if params[:tag_id]
      @query = Tag.find(params[:tag_id])
    elsif params[:tag_name]
      @query = Tag.find(:all, :conditions => {:name => params[:tag_name]}).first
    end
    
    respond_to do |format|
      format.xml {render :xml => @query}
      format.json {render :json => @query, :callback => params[:callback]}
    end
  end
  
protected
  
  #-------------------------------------#
  # Formats XML/JSON rendering of tags. #
  #-------------------------------------#
  
  def tag_response sound
    response = {
      :all_tags => sound.tags.join(', '),
      :all_tags_formatted => formatted_sound_tags(sound, :normal),
      :all_tags_formatted_old => formatted_sound_tags(sound, :old),
      'list_all_tags' => sound.tags
    }
    
    if logged_in?
      user_tags = current_user.owned_taggings.find(:all, :conditions => {:taggable_id => sound}).collect{|tagging| tagging.tag}
      response[:user_tags] = user_tags.join(', ')
      response[:list_user_tags] = user_tags
    end
    
    response
  end
end
