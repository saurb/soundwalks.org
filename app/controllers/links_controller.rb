class LinksController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  
  def index
    if current_user.admin?
      @links = Link.find(:all)
      
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
        flash.now[:notice] = "All links successfully destroyed."
        render :action => 'index'
      }
    end
  end
  
  protected
    def update_or_create_link(first, second, cost, distance)
      link = nil
      
      links = Link.find_with_nodes(first, second)
      
      if links != nil && links.size > 0
        link = links.first
      else
        link = Link.new
        link.first = first
        link.second = second
      end
      
      link.cost = cost if cost != nil
      link.distance = distance if distance != nil
      
      link.save
    end
end
