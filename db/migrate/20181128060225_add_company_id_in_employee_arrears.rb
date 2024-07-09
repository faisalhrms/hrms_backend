class AddCompanyIdInEmployeeArrears < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_arrears, :company_id, :integer
  end
end
