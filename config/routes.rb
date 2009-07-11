ActionController::Routing::Routes.draw do |map|
  map.resources :soundwalks, :has_many => :sounds  
  map.root :controller => 'soundwalks'
  
  map.recalculate 'soundwalks/:soundwalk_id/sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
  #map.recalculate 'sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
end
