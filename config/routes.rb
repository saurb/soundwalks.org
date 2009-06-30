ActionController::Routing::Routes.draw do |map|
  map.resources :sounds#, :path_names => { :recalculate => 'recalculate'}
  
  map.resources :soundwalks, :has_many => :sounds
  map.recalculate 'soundwalks/:soundwalk_id/sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
  map.recalculate 'sounds/:id/recalculate', :controller => 'sounds', :action => 'recalculate'
  
  map.root :controller => 'soundwalks'
end
