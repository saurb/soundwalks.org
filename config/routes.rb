ActionController::Routing::Routes.draw do |map|
  map.resources :soundwalks, :has_many => :sounds  
  map.root :controller => 'soundwalks'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format' 
  
  #map.recalculate 'soundwalks/:soundwalk_id/sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
  #map.recalculate 'sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
end
