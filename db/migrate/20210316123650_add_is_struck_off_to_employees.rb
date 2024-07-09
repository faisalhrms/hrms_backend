class AddIsStruckOffToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :is_struck_off, :boolean, default: false
  end
end
