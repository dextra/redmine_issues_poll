class AddBetVotesToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :bet_votes, :integer, :default => 0
    Issue.update_all(:bet_votes => 0)
  end

  def self.down
    remove_column :issues, :bet_votes
  end
end
