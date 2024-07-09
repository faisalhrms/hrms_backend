class CreateTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :time_slots do |t|
    	t.integer 		:company_id
    	t.integer 		:location_id
			t.string 			:name
			t.string 			:code
			t.string 			:actual_start_time
			t.string 			:actual_end_time
			t.datetime 		:start_time
			t.datetime 		:end_time
			t.float 			:start_buffer, 	:default => 0.0
			t.float 			:end_buffer, 		:default => 0.0
			t.boolean 		:is_active, 		:default => false
			t.text				:description
      t.timestamps
    end
    add_index :time_slots, :company_id
    add_index :time_slots, :location_id
  end
end
