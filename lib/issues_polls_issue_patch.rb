require_dependency 'issue'

module IssuesPollsIssuePatch
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
  end
  
end

Issue.send(:include, IssuesPollsIssuePatch) unless Issue.included_modules.include? IssuesPollsIssuePatch