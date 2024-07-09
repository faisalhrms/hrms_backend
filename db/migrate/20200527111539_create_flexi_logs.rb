class CreateFlexiLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :flexi_logs do |t|
    	t.string   :employee_full_name
	    t.string   :employee_code
	    t.string   :machine_name
	    t.datetime :attendance_datetime
	    t.datetime :attendance_date
	    t.string   :actual_attendance_date
	    t.integer  :formatted_hour
	    t.integer  :formatted_minute
	    t.integer  :formatted_second
	    t.string   :log_id
	    t.integer  :company_id
	    t.integer  :employee_id
      t.timestamps
    end
  end
end
