require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'issues_polls_issue_patch'
  require_dependency 'issues_polls_queries_helper_patch'
  require_dependency 'issues_polls_user_patch'
  require_dependency 'issues_polls_project_patch'
  require_dependency 'issues_polls_hook'
end

Redmine::Plugin.register :redmine_issues_polls do
  name 'Redmine Issues Polls'
  author 'Dextra Sistemas'
  description 'This is a plugin for Redmine to elect issues'
  version '0.0.1'
  url 'https://github.com/dextra/redmine_issues_polls'
  author_url 'http://www.dextra.com.br'
  
  project_module :issues_polls do
    permission :polls_config, :polls => [:index, :set_votes, :set_statuses, :update_votes]
    permission :bet, :polls => [:bet, :cancel_bet]
  end
  
  menu :project_menu, :polls, { :controller => 'polls', :action => 'index' }, :caption => :issue_polls_caption, :after => :activity, :param => :project_id
  
  activity_provider :bets
  
end


