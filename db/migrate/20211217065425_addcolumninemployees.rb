class Addcolumninemployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :mother_name, :string
  end
end
