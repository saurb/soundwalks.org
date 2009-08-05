# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  include AuthenticatedSystem
  include FormLabelHelper
  include PathHelper
  include ListHelper
  include StringHelper
  include TimeHelper
  
  helper :all
  protect_from_forgery
  filter_parameter_logging :password
  
  def create_meta
    @meta = Hash.new
    @meta[:title] = nil
    @meta[:description] = nil
  end
  
  before_filter :create_meta
end
