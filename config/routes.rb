ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.settings '/settings', :controller => 'users', :action => 'settings'
  
  map.resource :about, :controller => 'about', :member =>  {:developers => :get, :contact => :get}
  
  map.resource :admin, :controller => 'admin', :member => {
    :poll => :get,
    :sandbox => :get,
    :mds => :get,
    :links => :get,
    :tags => :get
  }
  
  map.resources :soundwalks, :member => {:locations => :get} do |soundwalks|
    soundwalks.resources :sounds, :collection => {:delete_multiple => :delete, :uploader => :get} do |sounds|
      # These can't be made using :member, because :member changes the id from :id to :sound_id. Not sure why.
      sounds.analyze    'analyze',            :controller => 'sounds', :action => 'analyze',    :method => 'get'
      sounds.query_set  'query_set.:format',  :controller => 'sounds', :action => 'query_set',  :method => 'get'
      
      sounds.resource :tags
    end
  end
  
  map.resources :tags, :collection => {:query_set => :get}
  
  map.resources :friendships
  map.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete}
  map.resource :session
  map.resource :home
  
  # Sound index for location-based queries.
  map.sounds '/sounds', :controller => 'sounds', :action => 'allindex', :method => 'get'
  map.formatted_sounds '/sounds.:format', :controller => 'sounds', :action => 'allindex', :method => 'get'
  
  # 2009-08 User study.
  map.study '/study', :controller => 'study', :action => 'index', :method => 'get'
  map.sendstudy '/sendstudy', :controller => 'study', :action => 'create', :method => 'post'
  
  # Username permalinks.
  map.username '/:username', :controller => 'users', :action => 'show'
  map.username_with_format '/:username.:format', :controller => 'users', :action => 'show'
  map.follow '/:username/follow', :controller => 'users', :action => 'follow'
  map.followers '/:username/followers', :controller => 'users', :action => 'followers'
  map.following '/:username/following', :controller => 'users', :action => 'following'
  
  map.root :controller => 'home', :action => 'index'
end
