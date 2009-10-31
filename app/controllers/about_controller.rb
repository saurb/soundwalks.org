class AboutController < ApplicationController
  layout 'site'
  
  def show
    respond_to do |format|
      format.html
    end
  end
end