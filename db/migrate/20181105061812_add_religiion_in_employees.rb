class AddReligiionInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :religion_id, 	:integer
  end
end
