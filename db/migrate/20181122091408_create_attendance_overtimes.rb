class CreateAttendanceOvertimes < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_overtimes do |t|
    	t.integer 	:company_id
			t.string 		:name
			t.string 		:code
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_overtimes, :company_id
  end
end
