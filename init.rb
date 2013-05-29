#  Copyright 2011/2012 Dextra Sistemas
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issues_poll_hook'

  require_dependency 'user'
  unless User.included_modules.include? IssuesPollUserPatch
    User.send(:include, IssuesPollUserPatch)
  end

  require_dependency 'project'
  unless Project.included_modules.include? IssuesPollProjectPatch
    Project.send(:include, IssuesPollProjectPatch)
  end
  
  require_dependency 'issue'
  unless Issue.included_modules.include? IssuesPollIssuePatch
    Issue.send(:include, IssuesPollIssuePatch)
  end

  if (Redmine::VERSION::MAJOR > 2) || (Redmine::VERSION::MAJOR == 2 && Redmine::VERSION::MINOR >= 3)
    require_dependency "issue_query"
    unless IssueQuery.included_modules.include?(IssuesPollQueryPatch)
      IssueQuery.send(:include, IssuesPollQueryPatch)
    end
  else
    require_dependency "query"
    unless Query.included_modules.include?(IssuesPollQueryPatch)
      Query.send(:include, IssuesPollQueryPatch)
    end
  end
end

Redmine::Plugin.register :redmine_issues_poll do
  name 'Redmine Issues Poll'
  author 'Dextra Sistemas'
  description 'This is a plugin for Redmine to elect issues'
  version '0.2.0'
  url 'https://github.com/dextra/redmine_issues_poll'
  author_url 'http://www.dextra.com.br'
  
  project_module :issues_poll do
    permission :issues_poll_config, :polls => [:index, :set_votes, :set_statuses, :update_votes]
    permission :issues_poll_bet, :polls => [:bet, :cancel_bet]
  end
  
  menu :project_menu, :issues_poll_menu, { :controller => 'polls', :action => 'index' }, :caption => :issue_polls_caption, :after => :activity, :param => :project_id
  
  activity_provider :bets
  
end


