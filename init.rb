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
  name 'Redmine Issues Polls plugin'
  author 'Dextra Sistemas'
  description 'This is a plugin for Redmine...................'
  version '0.0.1'
  url 'http://example.com/path/to/plugin......................'
  author_url 'http://www.dextra.com.br'
  
  project_module :issues_polls do
    permission :permission_polls_config, :polls => [:index, :set_hours, :set_statuses]
    permission :permission_bet, :polls => [:bet, :cancel_bet]
  end
  
  menu :project_menu, :polls, { :controller => 'polls', :action => 'index' }, :caption => :issue_polls_caption, :after => :activity, :param => :project_id
end


