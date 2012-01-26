require_dependency 'project'

module IssuesPollProjectPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      has_many :poll_votes
    end
    
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
end

Project.send(:include, IssuesPollProjectPatch) unless Project.included_modules.include? IssuesPollProjectPatch