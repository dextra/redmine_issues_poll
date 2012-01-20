class CreatePollVotes < ActiveRecord::Migration
  def self.up
    create_table :poll_votes do |t|
      t.column :votes, :integer
      t.column :project_id, :integer
      t.column :user_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :poll_votes
  end
end
