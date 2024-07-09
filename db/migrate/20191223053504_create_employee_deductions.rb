class CreateEmployeeDeductions < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_deductions do |t|
    	t.integer  :employee_id
	    t.float    :deduction_days,      default: 0.0
	    t.string   :deduction_type
	    t.datetime :start_date
	    t.datetime :end_date
	    t.datetime :deductions_month
	    t.boolean  :status,           		default: false
	    t.integer  :company_id
      t.timestamps
    end
  end
end
