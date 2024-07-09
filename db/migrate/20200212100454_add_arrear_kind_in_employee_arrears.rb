class AddArrearKindInEmployeeArrears < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_arrears, :arrear_kind, :string, :default => "Other"
  end
end
