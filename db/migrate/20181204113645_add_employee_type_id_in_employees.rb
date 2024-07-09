class AddEmployeeTypeIdInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :employee_type_id, :integer
  end
end
