ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.recalculate '/soundwalks/:soundwalk_id/sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'  
  
  map.resources :soundwalks, :has_many => :sounds
  map.resources :friendships
  map.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete}
  
  map.resource :session
  map.resource :home

  map.username '/:username', :controller => 'users', :action => 'show'
  map.follow '/:username/follow', :controller => 'users', :action => 'follow'
  map.followers '/:username/followers', :controller => 'users', :action => 'followers'
  map.following '/:username/following', :controller => 'users', :action => 'following'
  
  map.root :controller => 'home', :action => 'index'
end
