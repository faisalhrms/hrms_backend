class AddFamilyNumberInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :file_number, 	:string
  	add_column :employees, :family_number, :string
  end
end
