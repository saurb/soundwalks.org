ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.settings '/settings', :controller => 'users', :action => 'settings'
  
  map.resources :links, :collection => {:recalculate_sounds => :get, :recalculate_votes => :get, :recalculate_tags => :get, :recalculate_distances => :get, :delete_all => :get}
  
  map.resources :soundwalks do |soundwalks|
    soundwalks.resources :sounds, :collection => {:delete_multiple => :delete, :uploader => :get}, :member => {:analyze => :get} do |sounds|
      sounds.set_tags         'tags',           :controller => 'tags', :action => 'update', :method => 'post'
      sounds.tags             'tags',           :controller => 'tags', :action => 'index',  :method => 'get'
      sounds.formatted_tags   'tags.:format',   :controller => 'tags', :action => 'index',  :method => 'get'
      
      sounds.query_set            'query_set',          :controller => 'sounds', :action => 'query_set', :method => 'get'
      sounds.formatted_query_set  'query_set.:format',  :controller => 'sounds', :action => 'query_set', :method => 'get'
    end
  end
  
  map.resources :tags, :collection => {:query_set => :get}
  
  map.resources :friendships
  map.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete}
  
  map.resource :session
  map.resource :home
  
  map.sounds '/sounds', :controller => 'sounds', :action => 'allindex', :method => 'get'
  map.formatted_sounds '/sounds.:format', :controller => 'sounds', :action => 'allindex', :method => 'get'
  
  map.study '/study', :controller => 'study', :action => 'index', :method => 'get'
  map.sendstudy '/sendstudy', :controller => 'study', :action => 'create', :method => 'post'
  
  map.username '/:username', :controller => 'users', :action => 'show'
  map.follow '/:username/follow', :controller => 'users', :action => 'follow'
  map.followers '/:username/followers', :controller => 'users', :action => 'followers'
  map.following '/:username/following', :controller => 'users', :action => 'following'
  map.root :controller => 'home', :action => 'index'
  #map.root :controller => 'study', :action => 'index'
end
