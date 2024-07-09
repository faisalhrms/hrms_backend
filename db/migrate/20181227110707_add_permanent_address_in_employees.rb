class AddPermanentAddressInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, 					:permanent_address, 				:text
  	add_column :employee_relatives, :date_of_enrollment, 				:datetime
  	add_column :employee_relatives, :same_as_employee_address, 	:boolean, :default => false
  end
end
