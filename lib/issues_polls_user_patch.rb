require_dependency 'user'

module IssuesPollsUserPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      has_many :poll_hours
      has_many :bets
    end
    
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def polls_hours_project(project_id)
      hours = poll_hours.find(:first, :conditions => ["project_id = ?", project_id])
      hours.nil? ? nil : hours.hours
    end
    
    def can_bet?(project_id)
      available_hours = self.polls_hours_project(project_id)
      available_hours and available_hours > 0
    end
  end
  
end

User.send(:include, IssuesPollsUserPatch) unless User.included_modules.include? IssuesPollsUserPatch