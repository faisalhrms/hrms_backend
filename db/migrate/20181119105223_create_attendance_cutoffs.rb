class CreateAttendanceCutoffs < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_cutoffs do |t|
    	t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.string 		:name
			t.datetime 	:start_date
			t.datetime 	:end_date
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_cutoffs, :company_id
    add_index :attendance_cutoffs, :location_id
    add_index :attendance_cutoffs, :branch_id
  end
end
