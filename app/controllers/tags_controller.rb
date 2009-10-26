class TagsController < ApplicationController
  before_filter :login_required
  
  def index
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    
    user_tags = current_user.owned_taggings.find(:all, :conditions => {:taggable_id => @sound}).collect {|tagging| tagging.tag}
    
    respond_to do |format|
      response = {
        :all_tags => @sound.tags.join(', '),
        :user_tags => user_tags.join(', '),
        :all_tags_formatted => formatted_sound_tags(@sound)
      }
      
      format.xml {render :xml => response, :status => :ok}
      format.js {render :json => response, :status => :ok}
    end
  end
  
  def update
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    tags = params[:user_tags]
    
    current_user.tag(@sound, :with => tags, :on => :tags)
    
    user_tags = current_user.owned_taggings.find(:all, :conditions => {:taggable_id => @sound}).collect {|tagging| tagging.tag}
    
    respond_to do |format|
      response = {
        :all_tags => @sound.tags.join(', '),
        :user_tags => user_tags.join(', '),
        :all_tags_formatted => formatted_sound_tags(@sound)
      }
      
      format.xml {render :xml => response, :status => :ok}
      format.js {render :json => response, :status => :ok}
    end
  end
  
  def query_set
    if params[:tag_id]
      @query = Tag.find(params[:tag_id])
    elsif params[:tag_name]
      @query = Tag.find(:all, :conditions => {:name => params[:tag_name]}).first
    end
    
    respond_to do |format|
      format.xml {render :xml => @query, :status => :ok}
      format.js {render :json => @query, :status => :ok}
    end
  end
end
