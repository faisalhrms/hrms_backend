class AddInsuranceAllowedInQualification < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_relatives, :insurance_allowed, :boolean, :default => false
  end
end
