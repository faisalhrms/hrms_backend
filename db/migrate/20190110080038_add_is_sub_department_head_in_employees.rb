class AddIsSubDepartmentHeadInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, 	:is_sub_department_head, :boolean, :default => false
  	add_column :users, 			:is_sub_department_head, :boolean, :default => false
  end
end
