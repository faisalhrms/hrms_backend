class AddEmployeeCodePrefixInCompanies < ActiveRecord::Migration[7.1]
  def change
  	add_column :companies, :employee_code_prefix, :float, :default => 0.0
  end
end
