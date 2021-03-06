# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  include AuthenticatedSystem
  include FormLabelHelper
  include PathHelper
  include ListHelper
  include StringHelper
  include TimeHelper
  include WordnetHelper
  
  helper :all
  protect_from_forgery
  filter_parameter_logging :password
  
  #--------------------------------------------#
  # Calls a rake task with optional arguments. #
  #--------------------------------------------#
  
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map {|n, v| "#{n.to_s.upcase}='#{v}'"}
    system "#{$RAKE_PATH} #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end
end
