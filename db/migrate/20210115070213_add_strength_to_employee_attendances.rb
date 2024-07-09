class AddStrengthToEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_attendances, :in_strength, :boolean, :default => false
    add_column :employee_attendances, :over_strength, :boolean, :default => false
  end
end
