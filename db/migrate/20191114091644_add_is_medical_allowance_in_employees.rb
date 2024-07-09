class AddIsMedicalAllowanceInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :is_medical_allowance, :boolean, :default => false
  	add_column :employees, 		:is_medical_allowance, :boolean, :default => false
  end
end
