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

require_dependency 'issue'

module IssuesPollIssuePatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      has_many :bets
    end
    
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def can_receive_bet?
      EligibleStatus.find(:all).collect{|status| status.status_id}.include?(self.status_id)
    end
    
    def valid_bets
      self.bets.all(
        :select => "sum(votes) as sum_votes, user_id",
        :group => "user_id"
      ).select {|b| b.sum_votes.to_i > 0}
    end
  end
  
end

Issue.send(:include, IssuesPollIssuePatch) unless Issue.included_modules.include? IssuesPollIssuePatch