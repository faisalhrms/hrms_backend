class AddSameAsEmployeePermanentAddressInRelatives < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_relatives, :same_as_employee_permanent_address, 	:boolean, :default => false
  end
end
