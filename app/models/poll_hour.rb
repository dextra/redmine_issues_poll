class PollHour < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :project
  
end
