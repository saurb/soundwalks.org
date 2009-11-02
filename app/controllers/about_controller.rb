class AboutController < ApplicationController
  layout 'site'
  
  #------------#
  # GET /about #
  #------------#
  
  def show
    respond_to do |format|
      format.html
    end
  end
  
  #-----------------------#
  # GET /about/developers #
  #-----------------------#
  
  def developers
    respond_to do |format|
      format.html
    end
  end
  
  #--------------------#
  # GET /about/contact #
  #--------------------#
  
  def contact
    respond_to do |format|
      format.html
    end
  end
end