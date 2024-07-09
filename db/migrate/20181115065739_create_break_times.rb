class CreateBreakTimes < ActiveRecord::Migration[7.1]
  def change
    create_table :break_times do |t|
    	t.integer 		:time_slot_id
			t.string 			:name
			t.string 			:code
			t.string 			:actual_start_time
			t.string 			:actual_end_time
			t.datetime 		:start_time
			t.datetime 		:end_time
			t.boolean 		:excluded, 		:default => false
      t.timestamps
    end
    add_index :break_times, :time_slot_id
  end
end
