class AddGazettedToEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_attendances, :gazetted, :boolean,  :default => false
  end
end
