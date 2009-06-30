#RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|  
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  config.gem "geokit"
  #config.gem "plant-sirens-ruby", :source => "http://gems.github.com", :lib => "sirens-ruby"
  config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
  config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => "aasm"
  
  config.plugins = [:geokit, :google_maps, :all]

  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  config.time_zone = 'UTC'
end
