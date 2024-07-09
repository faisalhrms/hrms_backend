class AddDifferentFields < ActiveRecord::Migration[7.1]
  def change
  	add_column :designations, :grade_id, 				:integer
  	add_column :employees, 		:personal_email, 	:string
  	add_column :employees, 		:personal_number, :string
  end
end
