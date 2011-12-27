class AddBetHoursToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :bet_hours, :integer, :default => 0
  end

  def self.down
    remove_column :issues, :bet_hours
  end
end
