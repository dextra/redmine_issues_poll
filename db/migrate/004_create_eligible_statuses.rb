class CreateEligibleStatuses < ActiveRecord::Migration
  def self.up
    create_table :eligible_statuses do |t|
      t.column :status_id, :integer
    end
  end

  def self.down
    drop_table :eligible_statuses
  end
end
