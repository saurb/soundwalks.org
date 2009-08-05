class TagsController < ApplicationController
  before_filter :login_required
  
  def index
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    
    respond_to do |format|
      format.xml {render :xml => {:tags => @sound.tags}}
      format.js {render :json => {:tags => @sound.tags}}
    end
  end
  
  def update
    @soundwalk = Soundwalk.find(params[:soundwalk_id])
    @sound = @soundwalk.sounds.find(params[:sound_id])
    tags = params[:user_tags]
    
    current_user.tag(@sound, :with => tags, :on => :tags)
    
    user_tags = current_user.owned_taggings.find(:all, :conditions => {:taggable_id => @sound}).collect {|tagging| tagging.tag}
		
    respond_to do |format|
      format.xml {render :xml => {:all_tags => @sound.tags.join(', '), :user_tags => user_tags.join(', ')}, :status => :ok}
      format.js {render :json => {:all_tags => @sound.tags.join(', '), :user_tags => user_tags.join(', ')}, :status => :ok}
    end
  end
end
