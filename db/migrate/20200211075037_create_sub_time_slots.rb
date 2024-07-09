class CreateSubTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_time_slots do |t|
			t.integer  			:company_id
			t.integer  			:location_id
			t.integer  			:branch_id
			t.integer  			:time_slot_id
			t.string   			:name
			t.string   			:code
			t.string   			:actual_start_time
			t.string   			:actual_end_time
			t.datetime 			:start_time
			t.datetime 			:end_time
			t.float    			:start_buffer,          default: 0.0
			t.float    			:end_buffer,            default: 0.0
			t.boolean  			:is_active,             default: false
			t.text     			:description
			t.float    			:total_working_minutes, default: 0.0
      t.timestamps
    end
    add_index :sub_time_slots, :company_id
    add_index :sub_time_slots, :location_id
    add_index :sub_time_slots, :branch_id
    add_index :sub_time_slots, :time_slot_id
  end
end
