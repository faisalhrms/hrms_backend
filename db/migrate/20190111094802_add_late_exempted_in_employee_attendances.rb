class AddLateExemptedInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :late_exempted, :boolean, :default => false
  end
end
