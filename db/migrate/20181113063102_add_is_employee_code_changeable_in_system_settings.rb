class AddIsEmployeeCodeChangeableInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :is_employee_code_changeable, :boolean, :default => false
  end
end
