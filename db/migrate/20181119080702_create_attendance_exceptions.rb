class CreateAttendanceExceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_exceptions do |t|
    	t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.string 		:name
			t.string 		:attendance_exception_type
			t.float 		:grace_time, :default => 0.0
			t.datetime 	:start_date
			t.datetime 	:end_date
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_exceptions, :company_id
    add_index :attendance_exceptions, :location_id
    add_index :attendance_exceptions, :branch_id
  end
end
