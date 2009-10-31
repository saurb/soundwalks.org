ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.settings '/settings', :controller => 'users', :action => 'settings'
  
  map.resource :admin do |admin|
    admin.poll 'poll', :controller => 'admin', :action => 'poll', :method => 'get'
    admin.formatted_poll 'poll.:format', :controller => 'admin', :action => 'poll', :method => 'get'
    admin.sandbox 'sandbox', :controller => 'admin', :action => 'sandbox', :method => 'get'
    
    admin.mds 'mds', :controller => 'admin', :action => 'mds', :method => 'get'
    admin.mds_load_random 'mds_load_random', :controller => 'admin', :action => 'mds_load_random', :method => 'get'
    admin.mds_load_file 'mds_load_file', :controller => 'admin', :action => 'mds_load_file', :method => 'get'
    admin.mds_delete_all 'mds_delete_all', :controller => 'admin', :action => 'mds_delete_all', :method => 'get'
    
    admin.links 'links', :controller => 'admin', :action => 'links', :method => 'get'
    admin.links_delete_all 'links_delete_all', :controller => 'admin', :action => 'links_delete_all', :methed => 'get'
    admin.links_update_acoustic 'links_update_acoustic', :controller => 'admin', :action => 'links_update_acoustic', :method => 'get'
    admin.links_update_semantic 'links_update_semantic', :controller => 'admin', :action => 'links_update_semantic', :method => 'get'
    admin.links_update_social 'links_update_social', :controller => 'admin', :action => 'links_update_social', :method => 'get'
    admin.links_update_distances 'links_update_distances', :controller => 'admin', :action => 'links_update_distances', :method => 'get'
    
    admin.tags 'tags', :controller => 'admin', :action => 'tags', :method => 'get'
    admin.tags_frequency 'tags_frequency', :controller => 'admin', :action => 'tags_frequency', :method => 'get'
  end
  
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
  map.username_with_format '/:username.:format', :controller => 'users', :action => 'show'
  
  map.follow '/:username/follow', :controller => 'users', :action => 'follow'
  map.followers '/:username/followers', :controller => 'users', :action => 'followers'
  map.following '/:username/following', :controller => 'users', :action => 'following'
  map.root :controller => 'home', :action => 'index'
  #map.root :controller => 'study', :action => 'index'
end
