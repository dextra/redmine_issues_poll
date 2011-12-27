class CreatePollHours < ActiveRecord::Migration
  def self.up
    create_table :poll_hours do |t|
      t.column :hours, :integer
      t.column :project_id, :integer
      t.column :user_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :poll_hours
  end
end
