class AddFormatedMonthInEmployeeLoans < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_loan_details, :formated_month, :string
  end
end
