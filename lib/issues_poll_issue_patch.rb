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