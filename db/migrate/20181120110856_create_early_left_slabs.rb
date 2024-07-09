class CreateEarlyLeftSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :early_left_slabs do |t|
    	t.integer 	:early_left_id
    	t.integer 	:attendance_deduction_id
    	t.integer 	:fallback_id
    	t.float 		:start_minute, 	:default => 0.0
    	t.float 		:end_minute, 		:default => 0.0
      t.timestamps
    end
    add_index :early_left_slabs, :early_left_id
    add_index :early_left_slabs, :attendance_deduction_id
    add_index :early_left_slabs, :fallback_id
  end
end
