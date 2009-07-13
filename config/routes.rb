ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  
  map.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete}
  map.resource :session

  map.resources :soundwalks, :has_many => :sounds  
  map.root :controller => 'soundwalks'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format' 
end
