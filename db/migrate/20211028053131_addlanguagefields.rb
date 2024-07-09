class Addlanguagefields < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :language_second,     	:string
    add_column :employees, :language_third,     	:string
    add_column :employees, :inter_level,         	:string
    add_column :employees, :expert_level,       	:string

  end
end
