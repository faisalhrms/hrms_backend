class AddLanguagesInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :languages_level, 	:string
    add_column :employees, :other,     	:string
    add_column :employees, :languages,    	:text ,:default => ""
  end
end
