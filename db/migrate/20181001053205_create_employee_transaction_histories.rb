class CreateEmployeeTransactionHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_transaction_histories do |t|
    	t.integer			:employee_id
    	t.string			:transaction_type
    	t.string			:old_employee_status,       :default => ""
    	t.string			:new_employee_status,       :default => ""
    	t.float			    :old_gross_salary,          :default => 0.0
    	t.float			    :new_gross_salary,          :default => 0.0
    	t.string			:old_employment_status,     :default => ""
    	t.string			:new_employment_status,     :default => ""
    	t.datetime		    :transaction_date
      t.timestamps
    end
    add_index :employee_transaction_histories, :employee_id
  end
end
