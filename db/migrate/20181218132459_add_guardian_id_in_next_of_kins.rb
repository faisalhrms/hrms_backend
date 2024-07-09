class AddGuardianIdInNextOfKins < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_next_of_kins, :guardian_id, :integer
  end
end
