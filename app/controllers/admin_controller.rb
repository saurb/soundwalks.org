class AdminController < ApplicationController
  layout 'site'
  before_filter :login_required
  
  def poll
    if current_user.admin?
      value = Settings.find_by_var(params[:setting])
      
      if !value.nil?
        respond_to do |format|
          format.xml {render :xml => value}
          format.json {render :json => value}
        end
      else
        respond_to do |format|
          format.xml {render :xml => {:settings => {:value => false}}}
          format.json {render :json => {:settings => {:value => false}}, :callback => params[:callback]}
        end
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  def sandbox
    html_page_for_admins
  end

  def mds
    if current_user.admin?
      if params[:offset]
        @offset = params[:offset].to_i
      else
        @offset = 0
      end
      
      @nodes = MdsNode.find(:all, :limit => 20, :offset => params[:offset])
      
      @total_nodes = MdsNode.count
      
      respond_to do |format|
        format.html
      end
    else
      redirect_back_or_default '/'
    end
  end
    
  def tags
    if current_user.admin?
      if params[:offset]
        @offset = params[:offset].to_i
      else
        @offset = 0
      end
      
      @tags = Tag.find(:all, :limit => 20, :offset => params[:offset])
      
      @total_tags = Tag.count
      
      respond_to do |format|
        format.html
      end
    else
      redirect_back_or_default '/'
    end
  end
    
  def links
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
        format.json {render :json => @links, :callback => params[:callback]}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  protected
  
  def html_page_for_admins
    if current_user.admin?
      respond_to do |format|
        format.html
      end
    else
      redirect_back_or_default '/'
    end
  end
end
