class CreateAttendanceEarnings < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_earnings do |t|
    	t.integer 	:company_id
			t.string 	  :name
			t.string 		:earning_from
			t.string 		:earning_type
			t.float 		:multiplex, 		:default => 1
			t.float 		:earning_value, :default => 0
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_earnings, :company_id
  end
end
