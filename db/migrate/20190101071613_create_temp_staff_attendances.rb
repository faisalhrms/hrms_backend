class CreateTempStaffAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :temp_staff_attendances do |t|
			t.integer 	:company_id
			t.integer 	:temporary_staff_id
    	t.string 		:attendance_status
			t.datetime	:in_time
			t.datetime	:out_time
			t.datetime	:attendance_date
      t.timestamps
    end
    add_index :temp_staff_attendances, :company_id
    add_index :temp_staff_attendances, :temporary_staff_id
  end
end
