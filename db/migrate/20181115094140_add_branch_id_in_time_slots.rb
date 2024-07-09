class AddBranchIdInTimeSlots < ActiveRecord::Migration[7.1]
  def change
    add_column :time_slots, :branch_id, :integer
    add_index :time_slots, :branch_id
  end
end
