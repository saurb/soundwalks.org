require File.join(File.dirname(__FILE__), 'boot')

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
  
Rails::Initializer.run do |config|
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.gem "haml"
  config.gem "avatar"
  config.gem "geokit"
  config.gem "libxml-ruby", :lib => "libxml"
  config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => "aasm"
  config.gem "mattetti-googlecharts", :source => "http://gems.github.com", :lib => "gchart"
  config.gem "RedCloth"
  config.gem 'sirens'
  config.gem 'Linguistics'
  config.time_zone = 'UTC'
  
  config.active_record.observers = :user_observer
  
  config.action_view.field_error_proc = Proc.new { |html_tag, instance|
    "<span class=\"fieldWithErrors\">#{html_tag}</span>" 
  }
  
  config.load_paths += %W(#{RAILS_ROOT}/app/middleware)
end
