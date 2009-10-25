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
  
  def tags_frequencies
    if current_user.admin?
      Settings.tags_frequencies = 0
    
      call_rake 'tags:frequencies'
      flash[:notice] = 'Adding tag frequencies.'
      redirect_back_or_default '/admin/tags'
    else
      redirect_back_or_default '/'
    end
  end
  
  def tags_wordnet
    if current_user.admin?
      Settings.tags_wordnet = 0
    
      call_rake 'tags:wordnet'
      flash[:notice] = 'Adding properties from WordNet.'
      redirect_back_or_default '/admin/tags'
    else
      redirect_back_or_default '/'
    end
  end
  
  def tags_populate
    if current_user.admin?
      Settings.tags_populate = 0
    
      call_rake 'tags:populate'
      flash[:notice] = 'Populating tags from WordNet.'
      redirect_back_or_default '/admin/tags'
    else
      redirect_back_or_default '/'
    end
  end
  
  def tags_hypernyms
    if current_user.admin?
      Settings.tags_hypernyms = 0
    
      call_rake 'tags:hypernyms'
      flash[:notice] = 'Adding all hypenryms from WordNet.'
      redirect_back_or_default '/admin/tags'
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
