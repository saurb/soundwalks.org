ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.settings '/settings', :controller => 'users', :action => 'settings'
    
  map.resources :soundwalks do |soundwalks|
    soundwalks.resources :sounds, :collection => {:delete_multiple => :delete, :uploader => :get} do |sounds|
      sounds.set_tags 'tags', :controller => 'tags', :action => 'update', :method => 'put'
      sounds.tags 'tags', :controller => 'tags', :action => 'show', :method => 'get'
    end
  end
  
  map.resources :friendships
  map.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete}
  
  map.resource :session
  map.resource :home
  
  map.study '/study', :controller => 'study', :action => 'index', :method => 'get'
  map.sendstudy '/sendstudy', :controller => 'study', :action => 'create', :method => 'post'
  
  map.username '/:username', :controller => 'users', :action => 'show'
  map.follow '/:username/follow', :controller => 'users', :action => 'follow'
  map.followers '/:username/followers', :controller => 'users', :action => 'followers'
  map.following '/:username/following', :controller => 'users', :action => 'following'
  #map.root :controller => 'home', :action => 'index'
  map.root :controller => 'study', :action => 'index'
end
