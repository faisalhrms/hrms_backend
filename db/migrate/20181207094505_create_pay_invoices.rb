class CreatePayInvoices < ActiveRecord::Migration[7.1]
  def change
	create_table :pay_invoices do |t|
		t.integer 		:employee_id
		t.integer 		:pay_execution_id
		t.integer 		:fiscal_year_id
		t.integer 		:provident_fund_id
		t.integer 		:eobi_id
		t.integer 		:tax_slab_id
		t.integer 		:company_id
		t.integer 		:location_id
		t.integer 		:branch_id
		t.integer 		:department_id
		t.integer 		:sub_department_id
		t.integer 		:designation_id
		t.integer 		:job_title_id
		t.integer 		:grade_id
		t.integer 		:salary_unit_id
		t.integer 		:cost_center_id
		t.string   		:invoice_number
		t.text     		:slip_message
		t.float    		:total_earning,                	default: 0.0
		t.float    		:total_deduction,             	default: 0.0
		t.float    		:net_pay_amount,             		default: 0.0
		t.float    		:tax_amount,                    default: 0.0
		t.float    		:deduction_days,                default: 0.0
		t.float    		:over_time_hours,               default: 0.0
		t.float    		:off_day_payment,        				default: 0.0
		t.float    		:arrears_days,        					default: 0.0
		t.datetime 		:joining_date
		t.datetime 		:confirmation_date
		t.boolean  		:on_probation,                  default: false
		t.boolean  		:status,                        default: true
		t.boolean  		:is_locked,                     default: false
		t.timestamps
	end
	add_index :pay_invoices, :employee_id
	add_index :pay_invoices, :pay_execution_id
	add_index :pay_invoices, :fiscal_year_id
	add_index :pay_invoices, :provident_fund_id
	add_index :pay_invoices, :eobi_id
	add_index :pay_invoices, :tax_slab_id
	add_index :pay_invoices, :company_id
	add_index :pay_invoices, :location_id
	add_index :pay_invoices, :branch_id
	add_index :pay_invoices, :department_id
	add_index :pay_invoices, :sub_department_id
	add_index :pay_invoices, :designation_id
	add_index :pay_invoices, :job_title_id
	add_index :pay_invoices, :grade_id
	add_index :pay_invoices, :salary_unit_id
	add_index :pay_invoices, :cost_center_id
  end
end
