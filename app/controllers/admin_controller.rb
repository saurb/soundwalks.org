class AdminController < ApplicationController
  before_filter :login_required
  
  def poll
    if current_user.admin?
      value = Settings.find_by_var(params[:setting])
      
      respond_to do |format|
        format.xml {render :xml => value}
        format.js {render :js => value}
      end
    end
  end
end
