class CreateEmployeeSaleIncentives < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_sale_incentives do |t|
			t.integer  :company_id
			t.integer  :location_id
			t.integer  :branch_id
			t.integer  :employee_id
			t.string   :employee_code
			t.string   :employee_name
			t.float    :month_days,                      	default: 0.0
			t.float    :gross_salary,                    	default: 0.0
			t.float    :per_day_salary,                  	default: 0.0
			t.float    :present_days,                     default: 0.0
			t.float    :propionate,                      	default: 0.0
			t.float    :incentive_amount,                	default: 0.0
			t.float    :present_day_salary,              	default: 0.0
			t.float    :sale_value,                 			default: 0.0
			t.float    :loss_value,                 			default: 0.0
			t.float    :profit_value,               			default: 0.0
			t.float    :total_incentive,               		default: 0.0
			t.datetime :incentive_date
      t.timestamps
    end
    add_index :employee_sale_incentives, :company_id
    add_index :employee_sale_incentives, :location_id
    add_index :employee_sale_incentives, :branch_id
    add_index :employee_sale_incentives, :employee_id
  end
end
