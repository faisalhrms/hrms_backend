class AddIsEditedInEmployeeRosters < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_rosters, :is_edited, :boolean, :default => false
  end
end
