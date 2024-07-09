class CreateAttendanceDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_devices do |t|
    	t.string 		:name
			t.string 		:code
			t.integer 	:company_id
			t.boolean 	:is_active, :default => false
			t.integer 	:device_id
			t.string 		:device_type
			t.string 		:device_url
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_devices, :company_id
  end
end
