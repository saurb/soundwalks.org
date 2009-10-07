class LinksController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  
  def index
    if current_user.admin?
      if params[:offset]
        @offset = params[:offset].to_i
      else
        @offset = 0
      end
      
      @links = Link.find(:all, :limit => 20, :offset => params[:offset])
      
      @total_links = Link.count
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @links}
        format.js {render :json => @links}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  def set
    if current_user.admin?
      # Find the link, if it exists.
      @link = Link.find(:conditions => {:first_id => params[:first_id], :second_id => params[:second_id], :first_type => params[:first_type], :second_type => params[:second_type]})
      
      # If the link doesn't exist, create it.
      if !@link
        @link = Link.new
        @link.first_id = params[:first_id]
        @link.second_id = params[:second_id]
        @link.first_type = params[:first_type]
        @link.second_type = params[:second_type]
      end
      
      # Update the cost and save.
      @link.cost = params[:cost]
      
      @link.save
      
      # Respond to the client.
      respond_to do |format|
        format.xml {render :xml => @link}
        format.js {render :js => @link}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  def delete_all
    @links = Link.find(:all)
    @links.each do |link|
      link.destroy
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = 'All links successfully destroyed.'
        render :action => 'index'
      }
    end
  end
  
  def update_acoustic
    Settings.links_weights_acoustic = 0
    
    call_rake 'links:weights:acoustic'
    flash[:notice] = 'Computing acoustic links.'
    redirect_to links_path
  end
  
  def update_social
    Settings.links_weights_social = 0
    
    call_rake 'links:weights:social'
    flash[:notice] = 'Computing social links.'
    redirect_to links_path
  end
  
  def update_semantic
    Settings.links_weights_semantic = 0
    
    call_rake 'links:weights:semantic'
    flash[:notice] = 'Computing semantic links.'
    redirect_to links_path
  end
  
  def update_distances
    Settings.links_distances = 0
    
    call_rake 'links:distances'
    flash[:notice] = 'Computing shortest paths.'
    redirect_to links_path
  end
end
