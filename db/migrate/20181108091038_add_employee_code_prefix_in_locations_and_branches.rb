class AddEmployeeCodePrefixInLocationsAndBranches < ActiveRecord::Migration[7.1]
  def change
  	add_column :locations, 	:employee_code_prefix, :float, :default => 0.0
  	add_column :branches, 	:employee_code_prefix, :float, :default => 0.0
  end
end
