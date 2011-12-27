ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/polls/:action', :controller => 'polls'
end
