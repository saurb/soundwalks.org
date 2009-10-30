class AdminController < ApplicationController
  layout 'site'
  before_filter :login_required
  
  def poll
    if current_user.admin?
      value = Settings.find_by_var(params[:setting])
      
      if !value.nil?
        respond_to do |format|
          format.xml {render :xml => value}
          format.js {render :json => value}
        end
      else
        respond_to do |format|
          format.xml {render :xml => {:settings => {:value => false}}}
          format.js {render :json => {:settings => {:value => false}}}
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
  
  def mds_delete_all
    MdsNode.destroy_all
    @nodes = MdsNode.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = 'All MDS nodes successfully destroyed.'
        render :action => 'mds'
      }
    end
  end
  
  def mds_load_random
    if current_user.admin?
      Settings.mds_load = 0
    
      call_rake 'mds:load:random'
      flash[:notice] = 'Filling MDS positions with random values.'
      redirect_back_or_default '/admin/mds'
    else
      redirect_back_or_default '/'
    end
  end
  
  def mds_load_file
    if current_user.admin?
      Settings.mds_load = 0
    
      call_rake 'mds:load:file', :mds_file => '/data/studies/20090913-mds.csv'
      flash[:notice] = 'Loading MDS positions from file.'
      redirect_back_or_default '/admin/mds'
    else
      redirect_back_or_default '/'
    end
  end
  
  # Tags
  
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
  
  def tags_frequency
    if current_user.admin?
      Settings.tags_frequencies = 0
    
      call_rake 'wordnet:frequency', :ic_file => '/data/ic/ic-semcor.txt'
      flash[:notice] = 'Adding tag frequencies.'
      redirect_back_or_default '/admin/tags'
    else
      redirect_back_or_default '/'
    end
  end
  
  # Links
  
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
        format.js {render :json => @links}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  def links_delete_all
    if current_user.admin?
      Link.destroy_all
      @links = Link.find(:all)
      
      redirect_back_or_default '/admin/links'
    else
      redirect_back_or_default '/'
    end
  end
  
  def links_update_acoustic
    if current_user.admin?
      Settings.links_weights_acoustic = 0
    
      call_rake 'links:weights:acoustic'
      flash[:notice] = 'Computing acoustic links.'
      redirect_back_or_default '/admin/links'
    else
      redirect_back_or_default '/'
    end
  end
  
  def links_update_social
    if current_user.admin?
      Settings.links_weights_social = 0
    
      call_rake 'links:weights:social'
      flash[:notice] = 'Computing social links.'
      redirect_back_or_default '/admin/links'
    else
      redirect_back_or_default '/'
    end
  end
  
  def links_update_semantic
    if current_user.admin?
      Settings.links_weights_semantic = 0
    
      call_rake 'links:weights:semantic'
      flash[:notice] = 'Computing semantic links.'
      redirect_back_or_default '/admin/links'
    else
      redirect_back_or_default '/'
    end
  end
  
  def links_update_distances
    if current_user.admin?
      Settings.links_distances = 0
    
      call_rake 'links:distances'
      flash[:notice] = 'Computing shortest paths.'
      redirect_back_or_default '/admin/links'
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
