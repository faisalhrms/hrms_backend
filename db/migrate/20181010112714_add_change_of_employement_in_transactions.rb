class AddChangeOfEmployementInTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :old_grade_id, 					:integer
		add_column :employee_transaction_histories, :new_grade_id, 					:integer
		add_column :employee_transaction_histories, :old_designation_id, 		:integer
		add_column :employee_transaction_histories, :new_designation_id, 		:integer
		add_column :employee_transaction_histories, :old_job_title_id, 			:integer
		add_column :employee_transaction_histories, :new_job_title_id, 			:integer
		add_column :employee_transaction_histories, :old_salary_unit_id, 		:integer
		add_column :employee_transaction_histories, :new_salary_unit_id, 		:integer
		add_column :employee_transaction_histories, :old_cost_center_id, 		:integer
		add_column :employee_transaction_histories, :new_cost_center_id, 		:integer
  end
end