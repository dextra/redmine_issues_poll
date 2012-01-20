class CreateBets < ActiveRecord::Migration
  def self.up
    create_table :bets do |t|
      t.column :votes, :integer
      t.column :user_id, :integer
      t.column :issue_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :bets
  end
end
