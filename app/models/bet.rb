class Bet < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :user
  
  validates_presence_of :hours, :user_id, :issue_id
  
  def validate
    if self.user and self.issue and self.hours
      poll_hours = self.user.polls_hours_project(self.issue.project_id)
      
      if Bet.exists?(self)
        record = Bet.find(self.id)
        if poll_hours.nil? or (poll_hours and poll_hours < (self.hours - record.hours))
          self.errors.add_to_base(I18n.t(:error_not_enough_hours))
        end
      else
        if poll_hours.nil? or (poll_hours and poll_hours < self.hours)
          self.errors.add_to_base(I18n.t(:error_not_enough_hours))
        end
      end
      
    end
  end
  
end