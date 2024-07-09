class AddReligiionSectInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :religion_sect_id, 	:integer
  end
end
