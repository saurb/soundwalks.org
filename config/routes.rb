ActionController::Routing::Routes.draw do |map|
  map.resources :sounds
  map.resources :soundwalks, :has_many => :sounds
  
  map.root :controller => 'soundwalks'
end
