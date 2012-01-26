require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'issues_poll_issue_patch'
  require_dependency 'issues_poll_queries_helper_patch'
  require_dependency 'issues_poll_user_patch'
  require_dependency 'issues_poll_project_patch'
  require_dependency 'issues_poll_hook'
end

Redmine::Plugin.register :redmine_issues_poll do
  name 'Redmine Issues Poll'
  author 'Dextra Sistemas'
  description 'This is a plugin for Redmine to elect issues'
  version '0.0.1'
  url 'https://github.com/dextra/redmine_issues_poll'
  author_url 'http://www.dextra.com.br'
  
  project_module :issues_poll do
    permission :issues_poll_config, :polls => [:index, :set_votes, :set_statuses, :update_votes]
    permission :issues_poll_bet, :polls => [:bet, :cancel_bet]
  end
  
  menu :project_menu, :polls, { :controller => 'polls', :action => 'index' }, :caption => :issue_polls_caption, :after => :activity, :param => :project_id
  
  activity_provider :bets
  
end


