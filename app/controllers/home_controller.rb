class HomeController < ApplicationController
  layout 'site'
  
  def index
    if logged_in?
      @meta[:title] = "Friends' Activity"
      
      @pages =  (current_user.following_soundwalks(:limit => 20, :select => 'id').count / 20.0).ceil
      @page = (defined? params[:page]) ? params[:page].to_i : 0
      @soundwalks = current_user.following_soundwalks(:limit => 20, :offset => @page * 20)
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @soundwalks}
        format.json {render :json => @soundwalks, :callback => params[:callback]}
      end
    else
      @meta[:title] = 'Public Timeline'
      
      @pages =  (Soundwalk.count / 20.0).ceil
      @page = (defined? params[:page]) ? params[:page].to_i : 0
      @soundwalks = Soundwalk.find(:all, :limit => 20, :offset => @page * 20, :order => "created_at DESC, title", :conditions => {:privacy => 'public'})
      
      respond_to do |format|
        format.html {render :template => 'soundwalks/index'}
        format.xml {render :xml => @soundwalks}
        format.json {render :json => @soundwalks, :callback => params[:callback]}
      end
    end
  end
  
  def contact
    
  end
end
