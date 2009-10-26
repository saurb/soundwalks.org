class LinksController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  
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
end
