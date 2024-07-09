class AddSubDepartmentIdInEmployees < ActiveRecord::Migration[7.1]
	def change
		add_column :employees, :sub_department_id, :integer
		add_column :internees, :sub_department_id, :integer
		add_column :temporary_staffs, :sub_department_id, :integer

		add_index :employees, :sub_department_id
		add_index :internees, :sub_department_id
		add_index :temporary_staffs, :sub_department_id
	end
end
