class CreateRelaxationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :relaxation_requests do |t|
    	t.integer   :company_id
			t.integer   :employee_id
			t.integer   :attendance_type_id
			t.float   	:request_count, :default => 0.0
			t.datetime  :start_date
			t.datetime  :end_date
			t.datetime  :start_time
			t.datetime  :end_time
			t.string   	:request_status
			t.string   	:apply_status
			t.boolean   :is_cancelled, :default => false
			t.text   		:reason
      t.timestamps
    end
    add_index :relaxation_requests, :company_id
    add_index :relaxation_requests, :employee_id
    add_index :relaxation_requests, :attendance_type_id
  end
end
