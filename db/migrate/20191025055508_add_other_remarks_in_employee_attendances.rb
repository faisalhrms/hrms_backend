class AddOtherRemarksInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :other_remarks, :string, :default => ""
  end
end
