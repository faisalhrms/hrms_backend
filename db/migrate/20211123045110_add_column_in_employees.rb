class AddColumnInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :skills_second, :string
    add_column :employees, :skills_third , :string
    add_column :employees, :second_level,  :string
    add_column :employees, :third_level,   :string

  end
end
