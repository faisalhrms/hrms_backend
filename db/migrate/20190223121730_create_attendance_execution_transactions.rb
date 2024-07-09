class CreateAttendanceExecutionTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_execution_transactions do |t|
    	t.integer			:company_id
    	t.integer			:location_id
    	t.integer			:branch_id
    	t.integer			:department_id
    	t.string			:company_name
    	t.string			:location_name
    	t.string			:branch_name
    	t.string			:department_name
    	t.datetime		:start_date
    	t.datetime		:end_date
    	t.datetime		:execution_start_time
    	t.datetime		:execution_end_time
      t.timestamps
    end
    add_index :attendance_execution_transactions, :company_id
    add_index :attendance_execution_transactions, :location_id
    add_index :attendance_execution_transactions, :branch_id
    add_index :attendance_execution_transactions, :department_id
  end
end
