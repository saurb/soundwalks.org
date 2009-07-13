require File.join(File.dirname(__FILE__), 'boot')

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

ENV['GEM_PATH'] = '/home/brandon/.gem/ruby/gems/1.8:/usr/local/lib/ruby/gems/1.8'

Rails::Initializer.run do |config|  
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  config.gem "geokit"
  config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
  config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => "aasm"
  config.gem "mattetti-googlecharts", :source => "http://gems.github.com", :lib => "gchart"
  
  config.plugins = [:geokit, :google_maps, :all]

  config.time_zone = 'UTC'
  
  config.active_record.observers = :user_observer
end
