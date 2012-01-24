require_dependency 'user'

module IssuesPollsUserPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      has_many :poll_votes
      has_many :bets
    end
    
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def polls_votes_project(project_id)
      votes = poll_votes.find(:first, :conditions => ["project_id = ?", project_id])
      votes.nil? ? nil : votes.votes
    end
    
    def can_bet?(project_id, bet_votes)
      project = Project.find(project_id)
      available_votes = self.polls_votes_project(project_id)
      project.enabled_module_names.include?('issues_polls') and available_votes and available_votes > bet_votes
    end
    
    def votes_bet_by_issue(issue_id)
      self.bets.sum(:votes, :conditions => ["issue_id=?", issue_id])
    end
  end
  
end

User.send(:include, IssuesPollsUserPatch) unless User.included_modules.include? IssuesPollsUserPatch