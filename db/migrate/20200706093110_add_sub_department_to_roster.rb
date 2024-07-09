class AddSubDepartmentToRoster < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_rosters, :sub_department_id, :integer
  end
end
