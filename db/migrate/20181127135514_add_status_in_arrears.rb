class AddStatusInArrears < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_arrears, :status, :boolean, :default => false
  end
end

