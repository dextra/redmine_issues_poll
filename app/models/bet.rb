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

class Bet < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
  has_one :project, :through => :issue
  
  acts_as_event :title => Proc.new {|o| "#{o.issue.tracker.name} ##{o.issue.id} (#{o.issue.status}): #{o.issue.subject}"},
                :url => Proc.new {|o| {:controller => 'issues', :action => 'show', :id => o.issue.id}},
                :datetime => :created_at,
                :description => Proc.new {|o| o.votes > 0 ? I18n.t(:vote_added, :count => o.votes) : I18n.t(:vote_cancelled, :count => o.votes * -1)},
                :type => Proc.new {|o| o.votes > 0 ? "vote-added" : "vote-canceled"}
                
  
  acts_as_activity_provider :timestamp => "#{table_name}.created_at", 
    :find_options => {:include => [{:issue => :project}, :author]},
    :author_key => :user_id,
    :permission => :permission_bet

  
  validates_presence_of :votes, :author, :issue
  
  def validate
    if self.author
      has_author = true
    end
    
    if self.issue
      has_issue = true
      if not self.issue.can_receive_bet?
        self.errors.add_to_base(I18n.t(:error_issue_not_eligible))
      end
    end
    
    if has_author and has_issue and self.votes
      if self.votes > 0
        if not self.author.can_bet?(issue.project_id, self.votes)
          self.errors.add_to_base(I18n.t(:error_not_enough_votes))
        end
      else
        if self.author.votes_bet_by_issue(issue.id) <=0
          self.errors.add_to_base(I18n.t(:error_invalid_votes))
        end
      end
    end
    
    if self.votes and self.votes == 0
      self.errors.add_to_base(I18n.t(:error_invalid_votes))
    end
    
  end
  
end