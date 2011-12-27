class Bet < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :user
  
  validates_presence_of :hours, :user_id, :issue_id
  
  def validate
    if self.user and self.issue and self.hours
      poll_hours = self.user.polls_hours_project(self.issue.project_id)
      if poll_hours.nil? or (poll_hours and poll_hours < self.hours)
        self.erros.add_to_base(:error_not_enough_hours)
      end
    end
  end
  
  private
  
end