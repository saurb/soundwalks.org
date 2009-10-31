class AboutController < ApplicationController
  layout 'site'
  
  def show
    respond_to do |format|
      format.html
    end
  end
  
  def developers
    respond_to do |format|
      format.html
    end
  end
  
  def contact
    respond_to do |format|
      format.html
    end
  end
end