class AddReligionIdInHolidays < ActiveRecord::Migration[7.1]
  def change
  	add_column :holidays, :religion_id, 			:integer
  	add_column :holidays, :specific_religion, :boolean, :default => false
  end
end